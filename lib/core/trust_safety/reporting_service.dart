import 'package:flutter/material.dart';
import 'package:laqta/core/services/backend_api_client.dart';

class ReportingService {
  ReportingService({BackendApiClient? apiClient})
    : _apiClient = apiClient ?? BackendApiClient();

  final BackendApiClient _apiClient;

  Future<void> submitReport({
    required String targetType,
    required String targetId,
    required String reason,
    String? description,
  }) async {
    await _apiClient.post(
      '/reports',
      body: <String, dynamic>{
        'targetType': targetType,
        'targetId': targetId,
        'reason': reason,
        if (description != null && description.trim().isNotEmpty)
          'description': description.trim(),
      },
    );
  }

  Future<void> blockUser(String userId) async {
    await _apiClient.post('/users/$userId/block');
  }

  Future<void> unblockUser(String userId) async {
    await _apiClient.delete('/users/$userId/block');
  }
}

const reportReasonsAr = <String>[
  'محتوى غير لائق',
  'احتيال أو انتحال',
  'إساءة أو مضايقة',
  'صور مسروقة',
  'معلومات مضللة',
  'أخرى',
];

Future<void> showReportContentSheet({
  required BuildContext context,
  required String targetType,
  required String targetId,
  String? blockUserId,
  ReportingService? service,
}) async {
  final reporter = service ?? ReportingService();
  String selectedReason = reportReasonsAr.first;
  final descriptionController = TextEditingController();
  bool submitting = false;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'إرسال بلاغ',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedReason,
                    decoration: const InputDecoration(labelText: 'سبب البلاغ'),
                    items: reportReasonsAr
                        .map(
                          (reason) => DropdownMenuItem(
                            value: reason,
                            child: Text(reason),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: submitting
                        ? null
                        : (value) {
                            if (value != null) {
                              setState(() => selectedReason = value);
                            }
                          },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descriptionController,
                    minLines: 2,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'تفاصيل إضافية (اختياري)',
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: submitting
                        ? null
                        : () async {
                            setState(() => submitting = true);
                            try {
                              await reporter.submitReport(
                                targetType: targetType,
                                targetId: targetId,
                                reason: selectedReason,
                                description: descriptionController.text,
                              );
                              if (blockUserId != null) {
                                await reporter.blockUser(blockUserId);
                              }
                              if (!context.mounted) return;
                              Navigator.of(sheetContext).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'تم إرسال البلاغ، شكرًا لمساعدتنا في الحفاظ على أمان المجتمع.',
                                  ),
                                ),
                              );
                            } catch (_) {
                              if (!context.mounted) return;
                              setState(() => submitting = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'تعذّر إرسال البلاغ، حاول مرة أخرى.',
                                  ),
                                ),
                              );
                            }
                          },
                    child: submitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('إرسال البلاغ'),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );

  descriptionController.dispose();
}
