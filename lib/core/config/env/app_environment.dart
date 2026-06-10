abstract class AppEnvironmentConfig {
  const AppEnvironmentConfig({
    required this.name,
    required this.apiBaseUrl,
    required this.stripePublishableKey,
    required this.enableLogging,
    required this.enableRasp,
    required this.minioBaseUrl,
  });

  final String name;
  final String apiBaseUrl;
  final String stripePublishableKey;
  final bool enableLogging;
  final bool enableRasp;
  final String minioBaseUrl;
}
