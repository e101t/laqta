import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:laqta/core/services/backend_api_client.dart';
import 'package:laqta/core/services/backend_config.dart';

class BackendMediaService {
  BackendMediaService({
    BackendApiClient? backendApiClient,
    http.Client? httpClient,
  }) : _backendApi = backendApiClient ?? BackendApiClient(),
       _httpClient = httpClient ?? http.Client();

  final BackendApiClient _backendApi;
  final http.Client _httpClient;

  Future<String> uploadFile({
    required String entityType,
    required String entityId,
    required String filePath,
    required bool publicContent,
    String? fileName,
  }) async {
    final file = File(filePath);
    final mimeType = _detectMimeType(filePath);
    final size = await file.length();

    final uploadResponse = await _backendApi.post(
      '/media/upload-url',
      body: {
        'entityType': entityType,
        'entityId': entityId,
        'mimeType': mimeType,
        'size': size,
        if (fileName != null && fileName.trim().isNotEmpty) 'fileName': fileName,
      },
    );

    final uploadMap = _asMap(uploadResponse, 'Invalid upload URL response.');
    final uploadUrl = _asString(uploadMap['uploadUrl'], 'Missing upload URL.');
    final uploadToken = _asString(
      uploadMap['uploadToken'],
      'Missing upload token.',
    );

    final uploadResult = await _httpClient.put(
      Uri.parse(uploadUrl),
      headers: {'Content-Type': mimeType},
      body: await file.readAsBytes(),
    );

    if (uploadResult.statusCode < 200 || uploadResult.statusCode >= 300) {
      throw StateError(
        'Direct upload failed with status ${uploadResult.statusCode}',
      );
    }

    final completeResponse = await _backendApi.post(
      '/media/complete',
      body: {'uploadToken': uploadToken},
    );
    final completeMap = _asMap(completeResponse, 'Invalid upload completion.');
    final media = _asMap(completeMap['media'], 'Missing media payload.');
    final mediaId = _asString(media['id'], 'Missing media id.');

    return publicContent
        ? BackendConfig.mediaContentUrl(mediaId)
        : BackendConfig.mediaApiUrl(mediaId);
  }

  Future<void> deleteByUrl(String url) async {
    final mediaId = extractMediaId(url);
    if (mediaId == null) {
      throw StateError('Not a backend-managed media URL.');
    }
    await _backendApi.delete('/media/$mediaId');
  }

  Future<String> resolveDisplayUrl(String url) async {
    final mediaId = extractMediaId(url);
    if (mediaId == null || _isPublicContentUrl(url)) {
      return url;
    }

    final response = await _backendApi.get('/media/$mediaId');
    final responseMap = _asMap(response, 'Invalid media response.');
    return _asString(responseMap['downloadUrl'], 'Missing download URL.');
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

  static String _detectMimeType(String filePath) {
    final normalized = filePath.toLowerCase();
    if (normalized.endsWith('.png')) {
      return 'image/png';
    }
    if (normalized.endsWith('.webp')) {
      return 'image/webp';
    }
    if (normalized.endsWith('.mp4')) {
      return 'video/mp4';
    }
    if (normalized.endsWith('.mov')) {
      return 'video/quicktime';
    }
    if (normalized.endsWith('.zip')) {
      return 'application/zip';
    }
    if (normalized.endsWith('.pdf')) {
      return 'application/pdf';
    }
    if (normalized.endsWith('.txt')) {
      return 'text/plain';
    }
    if (normalized.endsWith('.doc')) {
      return 'application/msword';
    }
    if (normalized.endsWith('.docx')) {
      return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
    }
    if (normalized.endsWith('.xls')) {
      return 'application/vnd.ms-excel';
    }
    if (normalized.endsWith('.xlsx')) {
      return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
    }
    if (normalized.endsWith('.ppt')) {
      return 'application/vnd.ms-powerpoint';
    }
    if (normalized.endsWith('.pptx')) {
      return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
    }
    return 'image/jpeg';
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
