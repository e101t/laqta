import 'package:laqta/core/config/env/app_environment.dart';

class StagingConfig extends AppEnvironmentConfig {
  const StagingConfig()
    : super(
        name: 'staging',
        apiBaseUrl: const String.fromEnvironment(
          'BACKEND_BASE_URL',
          defaultValue: 'https://staging-api.laqta.cloud',
        ),
        stripePublishableKey: const String.fromEnvironment(
          'STRIPE_PUBLISHABLE_KEY',
          defaultValue: '',
        ),
        enableLogging: true,
        enableRasp: true,
        minioBaseUrl: const String.fromEnvironment(
          'MINIO_BASE_URL',
          defaultValue: 'https://staging-api.laqta.cloud',
        ),
      );
}
