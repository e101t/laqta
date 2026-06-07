import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:laqta/core/monitoring/crash_reporter.dart';
import 'package:laqta/core/security/monitoring/security_event_logger.dart';

class AppLogger {
  AppLogger._();

  static void d(String tag, String message) {
    if (kDebugMode) {
      developer.log('[$tag] ${_redact(message)}', name: 'LAQTA');
    }
  }

  static void i(String tag, String message) {
    if (!kReleaseMode) {
      developer.log('[$tag] ${_redact(message)}', name: 'LAQTA');
    }
  }

  static void e(
    String tag,
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    if (kDebugMode) {
      developer.log('[$tag] ERROR: ${_redact(message)}', name: 'LAQTA');
    }
    CrashReporter.logError(tag, _redact(message), error, stackTrace);
  }

  static void security(String event, {String severity = 'warning'}) {
    SecurityEventLogger.instance.log(event, severity: severity);
  }

  static String _redact(String value) {
    return value
        .replaceAll(RegExp(r'Bearer\s+[A-Za-z0-9._-]+'), 'Bearer REDACTED')
        .replaceAll(
          RegExp(
            r'(token|password|secret|client_secret)=([^&\s]+)',
            caseSensitive: false,
          ),
          r'$1=REDACTED',
        );
  }
}
