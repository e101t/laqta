import 'package:laqta/core/config/app_config.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class SentryFlutterService {
  SentryFlutterService._();

  static const _dsn = String.fromEnvironment('SENTRY_DSN', defaultValue: '');

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
    });
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
