import 'package:flutter/material.dart';
import 'package:laqta/core/localization/app_localizations.dart';
import 'package:laqta/core/services/backend_api_client.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  final _apiClient = BackendApiClient();
  late Future<List<Map<String, dynamic>>> _reportsFuture;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _reportsFuture = _fetchReports();
  }

  Future<List<Map<String, dynamic>>> _fetchReports() async {
    final response = await _apiClient.get('/admin/reports?sort=createdAt:desc');
    if (response is! Map<String, dynamic>) return const [];
    final list = response['reports'];
    if (list is! List) return const [];
    return list.whereType<Map<Object?, Object?>>().map(Map<String, dynamic>.from).toList();
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
    setState(_load);
  }

  Future<void> _deleteReport(String id) async {
    await _apiClient.delete('/admin/reports/$id');
    setState(_load);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(localizations.adminReports)),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _reportsFuture,
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
            return Center(child: Text(localizations.reportsEmpty));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index];
              final id = (data['id'] ?? data['reportId'] ?? '').toString();
              final reason = (data['reason'] ?? '').toString();
              final status = (data['status'] ?? '').toString();
              final reportType = (data['reportType'] ?? '').toString();
              final reportedUserName =
                  (data['reportedUserName'] ?? localizations.notSpecified).toString();
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
                    itemBuilder: (context) => [
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
          );
        },
      ),
    );
  }
}
