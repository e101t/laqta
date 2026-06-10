import 'package:laqta/core/config/env/app_environment.dart';

class DevConfig extends AppEnvironmentConfig {
  const DevConfig()
    : super(
        name: 'dev',
        apiBaseUrl: const String.fromEnvironment(
          'BACKEND_BASE_URL',
          defaultValue: 'http://10.0.2.2:4000',
        ),
        stripePublishableKey: const String.fromEnvironment(
          'STRIPE_PUBLISHABLE_KEY',
          defaultValue: '',
        ),
        enableLogging: true,
        enableRasp: false,
        minioBaseUrl: const String.fromEnvironment(
          'MINIO_BASE_URL',
          defaultValue: 'http://10.0.2.2:9000',
        ),
      );
}
