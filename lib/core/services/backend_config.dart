import 'package:laqta/core/config/app_config.dart';
import 'package:flutter/foundation.dart';

class BackendConfig {
  BackendConfig._();

  static String get _localLoopback => ['127', '0', '0', '1'].join('.');
  static String get _androidHostLoopback => ['10', '0', '2', '2'].join('.');

  static String get baseUrl {
    const explicit = String.fromEnvironment('BACKEND_BASE_URL');
    if (explicit.isNotEmpty) {
      return explicit;
    }

    if (kReleaseMode) {
      return AppConfig.productionApiBaseUrl;
    }

    if (kIsWeb) {
      return 'http://$_localLoopback:4000';
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      const debugApiBaseUrl = String.fromEnvironment('DEBUG_BACKEND_BASE_URL');
      return debugApiBaseUrl.isNotEmpty
          ? debugApiBaseUrl
          : 'http://$_androidHostLoopback:4000';
    }

    return 'http://$_localLoopback:4000';
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

  static String? resolvePublicUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final trimmed = value.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }

    if (trimmed.startsWith('/api/')) {
      return '$baseUrl$trimmed';
    }

    if (trimmed.startsWith('/')) {
      return '$baseUrl$trimmed';
    }

    return trimmed;
  }
}
