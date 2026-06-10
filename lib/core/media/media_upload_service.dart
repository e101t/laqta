import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:laqta/core/media/media_compressor.dart';
import 'package:laqta/core/network/certificate_pinning.dart';
import 'package:laqta/core/services/backend_api_client.dart';
import 'package:laqta/core/services/backend_config.dart';

class MediaUploadResult {
  const MediaUploadResult({required this.mediaId, required this.stableUrl});

  final String mediaId;
  final String stableUrl;
}

class MediaUploadService {
  MediaUploadService({
    BackendApiClient? backendApiClient,
    http.Client? httpClient,
    MediaCompressor? compressor,
  }) : _backendApi = backendApiClient ?? BackendApiClient(),
       _httpClient = httpClient ?? PinnedHttpClient(),
       _compressor = compressor ?? const MediaCompressor();

  final BackendApiClient _backendApi;
  final http.Client _httpClient;
  final MediaCompressor _compressor;

  Future<MediaUploadResult> upload({
    required String entityType,
    required String entityId,
    required String filePath,
    required bool publicContent,
    String? fileName,
    void Function(int sentBytes, int totalBytes)? onProgress,
  }) async {
    final prepared = await _compressor.prepareForUpload(filePath);
    try {
      final file = File(prepared.path);
      final mimeType = detectMimeType(prepared.path);
      final size = await file.length();

      final uploadResponse = await _backendApi.post(
        '/media/upload-url',
        body: {
          'entityType': entityType,
          'entityId': entityId,
          'mimeType': mimeType,
          'size': size,
          if (fileName != null && fileName.trim().isNotEmpty)
            'fileName': fileName,
        },
      );

      final uploadMap = _asMap(uploadResponse, 'Invalid upload URL response.');
      final uploadUrl = _asString(
        uploadMap['uploadUrl'],
        'Missing upload URL.',
      );
      final uploadToken = _asString(
        uploadMap['uploadToken'],
        'Missing upload token.',
      );

      await _putWithRetry(
        file: file,
        uploadUrl: uploadUrl,
        mimeType: mimeType,
        size: size,
        onProgress: onProgress,
      );

      final completeResponse = await _backendApi.post(
        '/media/complete',
        body: {'uploadToken': uploadToken},
      );
      final completeMap = _asMap(
        completeResponse,
        'Invalid upload completion.',
      );
      final media = _asMap(completeMap['media'], 'Missing media payload.');
      final mediaId = _asString(media['id'], 'Missing media id.');
      final stableUrl = publicContent
          ? BackendConfig.mediaContentUrl(mediaId)
          : BackendConfig.mediaApiUrl(mediaId);

      return MediaUploadResult(mediaId: mediaId, stableUrl: stableUrl);
    } finally {
      if (prepared.temporary) {
        unawaitedDelete(prepared.path);
      }
    }
  }

  Future<void> _putWithRetry({
    required File file,
    required String uploadUrl,
    required String mimeType,
    required int size,
    void Function(int sentBytes, int totalBytes)? onProgress,
  }) async {
    Object? lastError;
    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        await _putFile(
          file: file,
          uploadUrl: uploadUrl,
          mimeType: mimeType,
          size: size,
          onProgress: onProgress,
        );
        return;
      } catch (error) {
        lastError = error;
        if (attempt < 2) {
          await Future<void>.delayed(
            Duration(milliseconds: 400 * (1 << attempt)),
          );
        }
      }
    }
    throw StateError('Media upload failed after retries: $lastError');
  }

  Future<void> _putFile({
    required File file,
    required String uploadUrl,
    required String mimeType,
    required int size,
    void Function(int sentBytes, int totalBytes)? onProgress,
  }) async {
    final uploadRequest = http.StreamedRequest('PUT', Uri.parse(uploadUrl))
      ..headers['Content-Type'] = mimeType
      ..contentLength = size;

    final uploadResultFuture = _httpClient.send(uploadRequest);
    var sent = 0;
    await for (final chunk in file.openRead()) {
      sent += chunk.length;
      uploadRequest.sink.add(chunk);
      onProgress?.call(sent, size);
    }
    await uploadRequest.sink.close();
    final uploadResult = await uploadResultFuture;

    if (uploadResult.statusCode < 200 || uploadResult.statusCode >= 300) {
      throw StateError(
        'Direct upload failed with status ${uploadResult.statusCode}',
      );
    }
  }

  static String detectMimeType(String filePath) {
    final normalized = filePath.toLowerCase();
    if (normalized.endsWith('.jpg') || normalized.endsWith('.jpeg')) {
      return 'image/jpeg';
    }
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
    throw StateError('Unsupported file type for upload: $filePath');
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

void unawaitedDelete(String path) {
  File(path).delete().catchError((_) => File(path));
}
