import 'dart:async';

import 'package:flutter/material.dart';
import 'package:laqta/core/localization/app_localizations.dart';
import 'package:laqta/core/pagination/paginated_list_widget.dart';
import 'package:laqta/core/services/backend_api_client.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
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
    final path = '/admin/reports?sort=createdAt:desc&page=$page&limit=$pageSize'
        '${q.isNotEmpty ? '&search=${Uri.encodeComponent(q)}' : ''}';
    final response = await _apiClient.get(path);
    if (response is! Map<String, dynamic>) return const [];
    final list = response['items'];
    if (list is! List) return const [];
    return list
        .whereType<Map<Object?, Object?>>()
        .map(Map<String, dynamic>.from)
        .toList();
  }

  String _formatDate(dynamic value) {
    if (value is String) {
      final dt = DateTime.tryParse(value);
      if (dt != null) return '${dt.day}/${dt.month}/${dt.year}';
    }
    return '-';
  }

  Future<void> _updateStatus(String id, String status) async {
    await _apiClient.patch('/admin/reports/$id/status', body: {'status': status});
    if (mounted) setState(() => _refreshKey++);
  }

  Future<void> _deleteReport(String id) async {
    await _apiClient.delete('/admin/reports/$id');
    if (mounted) setState(() => _refreshKey++);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(localizations.adminReports)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'ابحث في البلاغات...',
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
              key: ValueKey('reports-$_searchQuery-$_refreshKey'),
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              onLoadMore: _fetchPage,
              emptyWidget: Center(child: Text(localizations.reportsEmpty)),
              itemBuilder: (context, data, index) {
                final id = (data['id'] ?? data['reportId'] ?? '').toString();
                final reason = (data['reason'] ?? '').toString();
                final status = (data['status'] ?? '').toString();
                final reportType = (data['reportType'] ?? '').toString();
                final reportedUserName =
                    (data['reportedUserName'] ?? localizations.notSpecified)
                        .toString();
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(reason, style: textTheme.titleMedium),
                    subtitle: Text(
                      '${localizations.typeLabel}: $reportType\n'
                      '${localizations.reportedLabel}: $reportedUserName\n'
                      '${localizations.statusLabel}: $status\n'
                      '${localizations.dateLabel}: ${_formatDate(data['createdAt'] ?? data['timestamp'])}',
                    ),
                    isThreeLine: true,
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'resolve') {
                          await _updateStatus(id, 'resolved');
                        } else if (value == 'dismiss') {
                          await _updateStatus(id, 'dismissed');
                        } else if (value == 'delete') {
                          await _deleteReport(id);
                        }
                      },
                      itemBuilder: (_) => [
                        PopupMenuItem(
                          value: 'resolve',
                          child: Text(localizations.markResolved),
                        ),
                        PopupMenuItem(
                          value: 'dismiss',
                          child: Text(localizations.dismiss),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text(localizations.delete),
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
