import 'dart:io' show Platform;

class BackendConfig {
  BackendConfig._();

  static String get baseUrl {
    const override = String.fromEnvironment('BACKEND_BASE_URL');
    if (override.isNotEmpty) {
      return override;
    }

    if (Platform.isAndroid) {
      return 'http://10.0.2.2:4000';
    }

    return 'http://127.0.0.1:4000';
  }

  static Uri apiUri(String path) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$baseUrl/api/v1$normalizedPath');
  }
}
