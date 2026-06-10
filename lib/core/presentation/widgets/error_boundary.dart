import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:laqta/core/monitoring/crash_reporter.dart';

class ErrorBoundary extends StatefulWidget {
  const ErrorBoundary({super.key, required this.child});

  final Widget child;

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;
  Key _subtreeKey = UniqueKey();
  String? _reportedId;

  @override
  void didUpdateWidget(covariant ErrorBoundary oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.child != widget.child && _error == null) {
      _subtreeKey = UniqueKey();
    }
  }

  void _capture(Object error, StackTrace? stackTrace) {
    CrashReporter.logFatal(error, stackTrace);
    if (!mounted) return;
    setState(() {
      _error = error;
      _stackTrace = stackTrace;
    });
  }

  void _retry() {
    setState(() {
      _error = null;
      _stackTrace = null;
      _reportedId = null;
      _subtreeKey = UniqueKey();
    });
  }

  Future<void> _report() async {
    final id = await CrashReporter.reportError(
      _error ?? 'unknown_error',
      _stackTrace,
    );
    if (!mounted) return;
    setState(() => _reportedId = id);
    ScaffoldMessenger.maybeOf(
      context,
    )?.showSnackBar(SnackBar(content: Text('تم إرسال التقرير: $id')));
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return _FriendlyErrorScreen(
        errorId: _reportedId,
        onRetry: _retry,
        onReport: _report,
      );
    }

    return _BoundaryScope(
      onError: _capture,
      child: KeyedSubtree(key: _subtreeKey, child: widget.child),
    );
  }
}

class _BoundaryScope extends StatelessWidget {
  const _BoundaryScope({required this.onError, required this.child});

  final void Function(Object error, StackTrace? stackTrace) onError;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    ErrorWidget.builder = (FlutterErrorDetails details) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onError(details.exception, details.stack);
      });
      if (kDebugMode) {
        return ErrorWidget(details.exception);
      }
      return _FriendlyErrorScreen(onRetry: () {}, onReport: () async {});
    };
    return child;
  }
}

class _FriendlyErrorScreen extends StatelessWidget {
  const _FriendlyErrorScreen({
    this.errorId,
    required this.onRetry,
    required this.onReport,
  });

  final String? errorId;
  final VoidCallback onRetry;
  final Future<void> Function() onReport;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    color: theme.colorScheme.error,
                    size: 56,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'حدث خطأ غير متوقع',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'يرجى إعادة تشغيل التطبيق',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                  if (errorId != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'رقم التقرير: $errorId',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                  const SizedBox(height: 22),
                  FilledButton(
                    onPressed: onRetry,
                    child: const Text('إعادة المحاولة'),
                  ),
                  TextButton(
                    onPressed: onReport,
                    child: const Text('إرسال تقرير'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
