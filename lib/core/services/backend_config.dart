import 'package:flutter/foundation.dart';

class BackendConfig {
  BackendConfig._();

  static const String _productionBaseUrl = 'https://api.laqta.cloud';

  static String get baseUrl {
    const override = String.fromEnvironment('BACKEND_BASE_URL');
    if (override.isNotEmpty) {
      return override;
    }

    if (kReleaseMode) {
      return _productionBaseUrl;
    }

    if (kIsWeb) {
      return 'http://127.0.0.1:4000';
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:4000';
    }

    return 'http://127.0.0.1:4000';
  }

  static bool get useBackendRequests =>
      const bool.fromEnvironment('LAQTA_USE_BACKEND_REQUESTS');

  static bool get useBackendChat =>
      const bool.fromEnvironment('LAQTA_USE_BACKEND_CHAT');

  static bool get useBackendDeliveries =>
      const bool.fromEnvironment('LAQTA_USE_BACKEND_DELIVERIES');

  static bool get useBackendDisputes =>
      const bool.fromEnvironment('LAQTA_USE_BACKEND_DISPUTES');

  static Uri apiUri(String path) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$baseUrl/api/v1$normalizedPath');
  }

  static Uri mediaApiUri(String mediaId) => apiUri('/media/$mediaId');

  static String mediaApiUrl(String mediaId) => mediaApiUri(mediaId).toString();

  static Uri mediaContentUri(String mediaId) =>
      apiUri('/media/$mediaId/content');

  static String mediaContentUrl(String mediaId) =>
      mediaContentUri(mediaId).toString();
}
