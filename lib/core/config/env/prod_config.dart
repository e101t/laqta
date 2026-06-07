import 'package:laqta/core/config/env/app_environment.dart';

class ProdConfig extends AppEnvironmentConfig {
  const ProdConfig()
    : super(
        name: 'prod',
        apiBaseUrl: const String.fromEnvironment(
          'BACKEND_BASE_URL',
          defaultValue: 'https://api.laqta.cloud',
        ),
        stripePublishableKey: const String.fromEnvironment(
          'STRIPE_PUBLISHABLE_KEY',
          defaultValue: '',
        ),
        enableLogging: false,
        enableRasp: true,
        minioBaseUrl: const String.fromEnvironment(
          'MINIO_BASE_URL',
          defaultValue: 'https://api.laqta.cloud',
        ),
      );
}
