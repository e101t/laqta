import 'package:flutter/material.dart';
import 'package:laqta/core/localization/app_localizations.dart';

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
    final localizations = AppLocalizations.resolve(context);
    final message = switch (errorType) {
      AppErrorType.network => localizations.errorNetworkMessage,
      AppErrorType.server => localizations.errorServerMessage,
      AppErrorType.auth => localizations.errorSessionExpired,
      AppErrorType.unknown => localizations.errorUnexpected,
    };
    return Center(
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
              child: Text(localizations.retry),
            ),
            if (errorType == AppErrorType.unknown && onReport != null)
              TextButton(
                onPressed: onReport,
                child: Text(localizations.sendReport),
              ),
          ],
        ),
      ),
    );
  }
}
