import 'dart:async';

import 'package:laqta/core/config/app_config.dart';
import 'package:laqta/core/monitoring/log_redactor.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class SentryFlutterService {
  SentryFlutterService._();

  static const _dsn = String.fromEnvironment('SENTRY_DSN', defaultValue: '');

  static bool get isEnabled => _dsn.isNotEmpty;

  static Future<void> initialize() async {
    if (_dsn.isEmpty) {
      return;
    }

    await SentryFlutter.init((options) {
      options.dsn = _dsn;
      options.environment = AppConfig.flavor;
      options.release = const String.fromEnvironment(
        'SENTRY_RELEASE',
        defaultValue: 'laqta-mobile@1.0.0',
      );
      options.sendDefaultPii = false;
      options.attachScreenshot = false;
      options.tracesSampleRate = AppConfig.flavor == 'prod' ? 0.05 : 0.0;
      options.beforeSend = _redactEvent;
    });
  }

  static FutureOr<SentryEvent?> _redactEvent(SentryEvent event, Hint hint) {
    final message = event.message;
    final redactedMessage = message == null
        ? null
        : SentryMessage(LogRedactor.redact(message.formatted));
    final exceptions = event.exceptions
        ?.map(
          (exception) => exception.copyWith(
            value: exception.value == null
                ? null
                : LogRedactor.redact(exception.value!),
          ),
        )
        .toList();
    return event.copyWith(message: redactedMessage, exceptions: exceptions);
  }

  static Future<void> captureError(
    Object error,
    StackTrace stackTrace, {
    String? hashedUserId,
    Map<String, Object?>? extras,
  }) async {
    if (_dsn.isEmpty) {
      return;
    }
    await Sentry.captureException(
      error,
      stackTrace: stackTrace,
      withScope: (scope) async {
        if (hashedUserId != null) {
          await scope.setUser(SentryUser(id: hashedUserId));
        }
        for (final entry in (extras ?? const <String, Object?>{}).entries) {
          final value = entry.value;
          if (value != null) {
            await scope.setContexts(entry.key, value);
          }
        }
      },
    );
  }

  static void addScreenBreadcrumb(String screen) {
    if (_dsn.isEmpty) return;
    Sentry.addBreadcrumb(
      Breadcrumb(
        category: 'navigation',
        message: screen,
        level: SentryLevel.info,
      ),
    );
  }
}
