import 'dart:async';

import 'package:flutter/material.dart';
import 'package:laqta/core/constants/app_constants.dart';
import 'package:laqta/core/localization/app_localizations.dart';
import 'package:laqta/core/pagination/paginated_list_widget.dart';
import 'package:laqta/core/services/backend_api_client.dart';
import 'package:laqta/features/notifications/domain/entities/notification_model.dart';
import 'package:laqta/features/notifications/notifications_dependencies.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final _apiClient = BackendApiClient();
  String _searchQuery = '';
  int _refreshKey = 0;
  Timer? _searchDebounce;

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      if (mounted) {
        setState(() {
          _searchQuery = value.trim();
          _refreshKey++;
        });
      }
    });
  }

  Future<List<Map<String, dynamic>>> _fetchPage(int page, int pageSize) async {
    final q = _searchQuery;
    final path = '/admin/users?sort=createdAt:desc&page=$page&limit=$pageSize'
        '${q.isNotEmpty ? '&search=${Uri.encodeComponent(q)}' : ''}';
    final response = await _apiClient.get(path);
    if (response is! Map<String, dynamic>) return const [];
    final list = response['users'];
    if (list is! List) return const [];
    return list
        .whereType<Map<Object?, Object?>>()
        .map(Map<String, dynamic>.from)
        .toList();
  }

  bool _isBlocked(List<dynamic>? blockedUsers) {
    return blockedUsers?.whereType<String>().contains(AppConstants.adminBlockMarker) ??
        false;
  }

  Future<void> _toggleBlock(String userId, List<dynamic>? blockedUsers) async {
    final current = blockedUsers?.whereType<String>().toList() ?? <String>[];
    if (_isBlocked(blockedUsers)) {
      current.remove(AppConstants.adminBlockMarker);
    } else {
      current.add(AppConstants.adminBlockMarker);
    }
    await _apiClient.patch('/admin/users/$userId', body: {'blockedUsers': current});
    if (mounted) setState(() => _refreshKey++);
  }

  Future<void> _sendWarning(String userId, String name) async {
    final localizations = AppLocalizations.of(context);
    try {
      final notification = NotificationModel(
        notificationId: '',
        userId: userId,
        title: 'Account warning',
        body: 'Your account received a warning from admin.',
        type: 'system',
        data: {'action': 'warning'},
        createdAt: DateTime.now(),
      );
      await NotificationsDependencies.createNotification().call(notification);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${localizations.warningSent} - $name')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.warningFailed)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(localizations.adminUsers)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'ابحث عن مستخدم...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: scheme.surfaceContainerHighest,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          Expanded(
            child: PaginatedListWidget<Map<String, dynamic>>(
              key: ValueKey('users-$_searchQuery-$_refreshKey'),
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              onLoadMore: _fetchPage,
              emptyWidget: Center(child: Text(localizations.usersEmpty)),
              itemBuilder: (context, data, index) {
                final userId = (data['id'] ?? data['userId'] ?? '').toString();
                final name =
                    (data['name'] ?? localizations.notSpecified).toString();
                final role = (data['role'] ?? '').toString();
                final governorate = (data['governorate'] ?? '').toString();
                final blockedUsers = data['blockedUsers'] as List<dynamic>?;
                final blocked = _isBlocked(blockedUsers);
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(name, style: textTheme.titleMedium),
                    subtitle: Text('$role • $governorate'),
                    leading: blocked
                        ? Icon(Icons.block, color: scheme.error)
                        : const Icon(Icons.person_outline),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'toggleBlock') {
                          await _toggleBlock(userId, blockedUsers);
                        } else if (value == 'warn') {
                          await _sendWarning(userId, name);
                        }
                      },
                      itemBuilder: (_) => [
                        PopupMenuItem(
                          value: 'toggleBlock',
                          child: Text(
                            blocked ? localizations.unblock : localizations.block,
                          ),
                        ),
                        PopupMenuItem(
                          value: 'warn',
                          child: Text(localizations.sendWarning),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
