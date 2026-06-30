import 'package:flutter/material.dart';
import 'package:laqta/core/constants/app_constants.dart';
import 'package:laqta/core/localization/app_localizations.dart';
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
  late Future<List<Map<String, dynamic>>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _usersFuture = _fetchUsers();
  }

  Future<List<Map<String, dynamic>>> _fetchUsers() async {
    final response = await _apiClient.get('/admin/users?sort=createdAt:desc');
    if (response is! Map<String, dynamic>) return const [];
    final list = response['users'];
    if (list is! List) return const [];
    return list.whereType<Map<Object?, Object?>>().map(Map<String, dynamic>.from).toList();
  }

  bool _isBlocked(List<dynamic>? blockedUsers) {
    return blockedUsers?.whereType<String>().contains(AppConstants.adminBlockMarker) ?? false;
  }

  Future<void> _toggleBlock(
    String userId,
    List<dynamic>? blockedUsers,
  ) async {
    final current = blockedUsers?.whereType<String>().toList() ?? <String>[];
    final blocked = _isBlocked(blockedUsers);
    if (blocked) {
      current.remove(AppConstants.adminBlockMarker);
    } else {
      current.add(AppConstants.adminBlockMarker);
    }
    await _apiClient.patch('/admin/users/$userId', body: {'blockedUsers': current});
    setState(_load);
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
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(localizations.warningFailed)));
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
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: TextButton(
                onPressed: () => setState(_load),
                child: Text(localizations.retry),
              ),
            );
          }

          final docs = snapshot.data ?? [];
          if (docs.isEmpty) {
            return Center(child: Text(localizations.usersEmpty));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index];
              final userId = (data['id'] ?? data['userId'] ?? '').toString();
              final name = (data['name'] ?? localizations.notSpecified).toString();
              final role = (data['role'] ?? '').toString();
              final governorate = (data['governorate'] ?? '').toString();
              final blockedUsers = data['blockedUsers'] as List<dynamic>?;
              final blocked = _isBlocked(blockedUsers);
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(name, style: textTheme.titleMedium),
                  subtitle: Text('$role • $governorate'),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'toggleBlock') {
                        await _toggleBlock(userId, blockedUsers);
                      } else if (value == 'warn') {
                        await _sendWarning(userId, name);
                      }
                    },
                    itemBuilder: (context) => [
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
                  leading: blocked
                      ? Icon(Icons.block, color: scheme.error)
                      : const Icon(Icons.person_outline),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
