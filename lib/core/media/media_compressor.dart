import 'dart:io';

import 'package:image/image.dart' as image_lib;
import 'package:laqta/core/config/app_config.dart';

class MediaCompressionResult {
  const MediaCompressionResult({required this.path, required this.temporary});

  final String path;
  final bool temporary;
}

class MediaCompressor {
  const MediaCompressor();

  Future<MediaCompressionResult> prepareForUpload(String filePath) async {
    final normalized = filePath.toLowerCase();
    if (_isImage(normalized)) {
      return _compressImage(filePath);
    }
    if (_isVideo(normalized)) {
      return _validateVideo(filePath);
    }
    return MediaCompressionResult(path: filePath, temporary: false);
  }

  Future<MediaCompressionResult> _compressImage(String filePath) async {
    final original = File(filePath);
    final bytes = await original.readAsBytes();
    final decoded = image_lib.decodeImage(bytes);
    if (decoded == null) {
      return MediaCompressionResult(path: filePath, temporary: false);
    }

    final maxSide = AppConfig.maxUploadImageDimension;
    final longestSide = decoded.width > decoded.height
        ? decoded.width
        : decoded.height;
    final image = longestSide > maxSide
        ? image_lib.copyResize(
            decoded,
            width: decoded.width >= decoded.height ? maxSide : null,
            height: decoded.height > decoded.width ? maxSide : null,
            interpolation: image_lib.Interpolation.average,
          )
        : decoded;

    final output = File(
      '${Directory.systemTemp.path}${Platform.pathSeparator}laqta_upload_${DateTime.now().microsecondsSinceEpoch}.jpg',
    );
    await output.writeAsBytes(
      image_lib.encodeJpg(image, quality: AppConfig.uploadImageQuality),
      flush: true,
    );
    return MediaCompressionResult(path: output.path, temporary: true);
  }

  Future<MediaCompressionResult> _validateVideo(String filePath) async {
    final size = await File(filePath).length();
    if (size > AppConfig.maxUploadVideoBytes) {
      throw StateError('Video exceeds the maximum upload size.');
    }
    return MediaCompressionResult(path: filePath, temporary: false);
  }

  bool _isImage(String path) =>
      path.endsWith('.jpg') ||
      path.endsWith('.jpeg') ||
      path.endsWith('.png') ||
      path.endsWith('.webp');

  bool _isVideo(String path) => path.endsWith('.mp4') || path.endsWith('.mov');
}
