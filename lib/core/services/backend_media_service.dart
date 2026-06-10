import 'package:laqta/core/media/media_upload_service.dart';
import 'package:laqta/core/services/backend_api_client.dart';
import 'package:laqta/core/services/backend_config.dart';

class BackendMediaUploadResult {
  const BackendMediaUploadResult({
    required this.mediaId,
    required this.stableUrl,
  });

  final String mediaId;
  final String stableUrl;
}

class BackendMediaService {
  BackendMediaService({
    BackendApiClient? backendApiClient,
    MediaUploadService? uploadService,
  }) : _backendApi = backendApiClient ?? BackendApiClient(),
       _uploadService =
           uploadService ??
           MediaUploadService(backendApiClient: backendApiClient);

  final BackendApiClient _backendApi;
  final MediaUploadService _uploadService;
  static const int _maxDisplayUrlCacheEntries = 256;
  static final Map<String, Future<String>> _displayUrlCache =
      <String, Future<String>>{};

  Future<BackendMediaUploadResult> uploadFileReference({
    required String entityType,
    required String entityId,
    required String filePath,
    required bool publicContent,
    String? fileName,
  }) async {
    final result = await _uploadService.upload(
      entityType: entityType,
      entityId: entityId,
      filePath: filePath,
      publicContent: publicContent,
      fileName: fileName,
    );
    return BackendMediaUploadResult(
      mediaId: result.mediaId,
      stableUrl: result.stableUrl,
    );
  }

  Future<String> uploadFile({
    required String entityType,
    required String entityId,
    required String filePath,
    required bool publicContent,
    String? fileName,
  }) async {
    final result = await uploadFileReference(
      entityType: entityType,
      entityId: entityId,
      filePath: filePath,
      publicContent: publicContent,
      fileName: fileName,
    );
    return result.stableUrl;
  }

  Future<void> deleteByUrl(String url) async {
    final mediaId = extractMediaId(url);
    if (mediaId == null) {
      throw StateError('Not a backend-managed media URL.');
    }
    await _backendApi.delete('/media/$mediaId');
    _displayUrlCache.remove(url);
  }

  Future<String> resolveDisplayUrl(String url) async {
    final mediaId = extractMediaId(url);
    if (mediaId == null || _isPublicContentUrl(url)) {
      return url;
    }

    final cached = _displayUrlCache[url];
    if (cached != null) {
      return cached;
    }

    if (_displayUrlCache.length >= _maxDisplayUrlCacheEntries) {
      _displayUrlCache.remove(_displayUrlCache.keys.first);
    }

    final future = _resolvePrivateDisplayUrl(mediaId, url);
    _displayUrlCache[url] = future;
    return future;
  }

  Future<String> _resolvePrivateDisplayUrl(String mediaId, String url) async {
    try {
      final response = await _backendApi.get('/media/$mediaId');
      final responseMap = _asMap(response, 'Invalid media response.');
      return _asString(responseMap['downloadUrl'], 'Missing download URL.');
    } catch (_) {
      _displayUrlCache.remove(url);
      rethrow;
    }
  }

  static void clearDisplayUrlCache() {
    _displayUrlCache.clear();
  }

  static String? extractMediaId(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      return null;
    }

    final segments = uri.pathSegments;
    final mediaIndex = segments.indexOf('media');
    if (mediaIndex == -1 || mediaIndex + 1 >= segments.length) {
      return null;
    }

    final mediaId = segments[mediaIndex + 1];
    return mediaId.isEmpty ? null : mediaId;
  }

  static String requireMediaId(String url) {
    final mediaId = extractMediaId(url);
    if (mediaId == null) {
      throw StateError('Missing backend media id in URL.');
    }
    return mediaId;
  }

  static String mediaApiUrlFromId(String mediaId) {
    return BackendConfig.mediaApiUrl(mediaId);
  }

  static String mediaContentUrlFromId(String mediaId) {
    return BackendConfig.mediaContentUrl(mediaId);
  }

  static bool _isPublicContentUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      return false;
    }
    final segments = uri.pathSegments;
    final mediaIndex = segments.indexOf('media');
    if (mediaIndex == -1 || mediaIndex + 2 >= segments.length) {
      return false;
    }
    return segments[mediaIndex + 2] == 'content';
  }

  static Map<String, dynamic> _asMap(dynamic value, String message) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    throw StateError(message);
  }

  static String _asString(dynamic value, String message) {
    if (value is String && value.isNotEmpty) {
      return value;
    }
    throw StateError(message);
  }
}
