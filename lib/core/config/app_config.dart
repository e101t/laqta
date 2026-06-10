import 'package:laqta/core/config/env/app_environment.dart';
import 'package:laqta/core/config/env/dev_config.dart';
import 'package:laqta/core/config/env/prod_config.dart';
import 'package:laqta/core/config/env/staging_config.dart';

class AppConfig {
  AppConfig._();

  static const String flavor = String.fromEnvironment(
    'FLAVOR',
    defaultValue: 'prod',
  );

  static AppEnvironmentConfig get environment {
    switch (flavor) {
      case 'dev':
      case 'development':
        return const DevConfig();
      case 'staging':
        return const StagingConfig();
      case 'prod':
      case 'production':
      default:
        return const ProdConfig();
    }
  }

  static const String productionApiBaseUrl = String.fromEnvironment(
    'BACKEND_BASE_URL',
    defaultValue: 'https://api.laqta.cloud',
  );

  static String get apiBaseUrl {
    const explicit = String.fromEnvironment('BACKEND_BASE_URL');
    if (explicit.isNotEmpty) {
      return explicit;
    }
    if (flavor == 'staging' || flavor == 'development' || flavor == 'dev') {
      return environment.apiBaseUrl;
    }
    return productionApiBaseUrl;
  }

  static const String stripePublishableKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
    defaultValue: '',
  );

  static const String googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
    defaultValue:
        '1002424043359-c4ovhb6h19bq9b32rjlituihc3roou13.apps.googleusercontent.com',
  );

  static const bool certificatePinningEnabled = bool.fromEnvironment(
    'CERTIFICATE_PINNING_ENABLED',
    defaultValue: true,
  );

  static const bool disableCertificatePinning = bool.fromEnvironment(
    'DISABLE_PINNING',
    defaultValue: false,
  );

  static const String apiPrimaryPinSha256 = String.fromEnvironment(
    'API_PRIMARY_PIN_SHA256',
    defaultValue: 'jPK4/dMCJ072cH/Zur1TpXVv3B3tRZPGcDAnY3EmAe8=',
  );

  static const String apiBackupPinSha256 = String.fromEnvironment(
    'API_BACKUP_PIN_SHA256',
    defaultValue: 'W9ELcuhvtNd5YqeF3RryTdb8KjUuFuHsKcqApPe3CZ0=',
  );

  static const String additionalPinnedHosts = String.fromEnvironment(
    'ADDITIONAL_PINNED_HOSTS',
    defaultValue: '',
  );

  static const int playIntegrityCloudProjectNumber = int.fromEnvironment(
    'PLAY_INTEGRITY_CLOUD_PROJECT_NUMBER',
    defaultValue: 1002424043359,
  );

  static const bool playIntegrityRequired = bool.fromEnvironment(
    'PLAY_INTEGRITY_REQUIRED',
    defaultValue: false,
  );

  static const String playIntegrityVerifyPath = String.fromEnvironment(
    'PLAY_INTEGRITY_VERIFY_PATH',
    defaultValue: '/security/play-integrity/verify',
  );

  static const String requestSigningSecret = String.fromEnvironment(
    'REQUEST_SIGNING_SECRET',
    defaultValue: '',
  );

  static const bool requestSigningEnabled = bool.fromEnvironment(
    'REQUEST_SIGNING_ENABLED',
    defaultValue: true,
  );

  static const String jwtIssuer = String.fromEnvironment(
    'JWT_ISSUER',
    defaultValue: 'https://api.laqta.cloud',
  );

  static const String jwtAudience = String.fromEnvironment(
    'JWT_AUDIENCE',
    defaultValue: 'laqta-app',
  );

  static const bool securityEventsEnabled = bool.fromEnvironment(
    'SECURITY_EVENTS_ENABLED',
    defaultValue: true,
  );

  static const int biometricBackgroundMinutes = int.fromEnvironment(
    'BIOMETRIC_BACKGROUND_MINUTES',
    defaultValue: 5,
  );

  static const int maxUploadImageDimension = int.fromEnvironment(
    'MAX_UPLOAD_IMAGE_DIMENSION',
    defaultValue: 1200,
  );

  static const int uploadImageQuality = int.fromEnvironment(
    'UPLOAD_IMAGE_QUALITY',
    defaultValue: 85,
  );

  static const int maxUploadVideoBytes = int.fromEnvironment(
    'MAX_UPLOAD_VIDEO_BYTES',
    defaultValue: 104857600,
  );
}
