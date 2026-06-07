import 'dart:io';

import 'package:image_picker/image_picker.dart';

typedef VideoPickerOverride = Future<XFile?> Function(ImageSource source);

class VideoPickerService {
  VideoPickerService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  Future<XFile?> pickVideoToTemp({
    required ImageSource source,
    VideoPickerOverride? pickerOverride,
  }) async {
    final picked = pickerOverride != null
        ? await pickerOverride(source)
        : await _picker.pickVideo(source: source);
    if (picked == null) {
      return null;
    }

    final tempDirectory = await Directory.systemTemp.createTemp(
      'laqta_video_picker_',
    );
    final fileName = _safeFileName(picked);
    final tempFile = File(
      '${tempDirectory.path}${Platform.pathSeparator}$fileName',
    );

    final sink = tempFile.openWrite();
    try {
      await for (final chunk in picked.openRead()) {
        sink.add(chunk);
      }
    } finally {
      await sink.close();
    }

    return XFile(
      tempFile.path,
      name: fileName,
      mimeType: picked.mimeType ?? _inferVideoMimeType(fileName),
    );
  }

  String _safeFileName(XFile file) {
    final rawName = file.name.trim().isNotEmpty
        ? file.name.trim()
        : file.path.split(RegExp(r'[\\/]')).last;
    final sanitized = rawName
        .replaceAll(RegExp(r'[^a-zA-Z0-9._-]+'), '_')
        .replaceAll(RegExp(r'_+'), '_');
    if (sanitized.contains('.') && !sanitized.endsWith('.')) {
      return sanitized;
    }
    return '${sanitized.isEmpty ? 'video' : sanitized}.mp4';
  }

  String _inferVideoMimeType(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.mov')) {
      return 'video/quicktime';
    }
    if (lower.endsWith('.webm')) {
      return 'video/webm';
    }
    if (lower.endsWith('.mkv')) {
      return 'video/x-matroska';
    }
    return 'video/mp4';
  }
}
