import 'package:laqta/core/utils/legacy_data_compat.dart';
import 'package:flutter/material.dart';
import 'package:laqta/core/localization/app_localizations.dart';
import 'package:laqta/core/security/secure_firestore.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  final LegacyDataStore _firestore = LegacyDataStore.instance;
  late final SecureFirestore _secure = SecureFirestore(_firestore);

  String _formatTimestamp(dynamic value) {
    if (value is Timestamp) {
      final date = value.toDate();
      return '${date.day}/${date.month}/${date.year}';
    }
    return '-';
  }

  Future<void> _updateStatus(
    DocumentReference<Map<String, dynamic>> ref,
    String status,
  ) async {
    await _secure.guard(() => ref.update({'status': status}));
  }

  Future<void> _deleteReport(
    DocumentReference<Map<String, dynamic>> ref,
  ) async {
    await _secure.guard(() => ref.delete());
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(localizations.adminReports)),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _firestore
            .collection('reports')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: TextButton(
                onPressed: () => setState(() {}),
                child: Text(localizations.retry),
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return Center(child: Text(localizations.reportsEmpty));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data();
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
                    '${localizations.dateLabel}: ${_formatTimestamp(data['timestamp'])}',
                  ),
                  isThreeLine: true,
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'resolve') {
                        await _updateStatus(doc.reference, 'resolved');
                      } else if (value == 'dismiss') {
                        await _updateStatus(doc.reference, 'dismissed');
                      } else if (value == 'delete') {
                        await _deleteReport(doc.reference);
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
