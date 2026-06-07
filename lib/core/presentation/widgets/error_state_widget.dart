import 'package:flutter/material.dart';

enum AppErrorType { network, server, auth, unknown }

class ErrorStateWidget extends StatelessWidget {
  const ErrorStateWidget({
    super.key,
    required this.errorType,
    required this.onRetry,
    this.onReport,
  });

  final AppErrorType errorType;
  final VoidCallback onRetry;
  final VoidCallback? onReport;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final message = switch (errorType) {
      AppErrorType.network => 'تحقق من اتصالك بالإنترنت',
      AppErrorType.server => 'حدث خطأ في الخادم، يرجى المحاولة لاحقاً',
      AppErrorType.auth => 'انتهت جلستك',
      AppErrorType.unknown => 'حدث خطأ غير متوقع',
    };
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 46,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 12),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 14),
              FilledButton(
                onPressed: onRetry,
                child: const Text('إعادة المحاولة'),
              ),
              if (errorType == AppErrorType.unknown && onReport != null)
                TextButton(
                  onPressed: onReport,
                  child: const Text('إرسال تقرير'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
