import 'dart:io';

import 'package:image_picker/image_picker.dart';

typedef ImagePickerOverride = Future<XFile?> Function(ImageSource source);

class ImagePickerService {
  ImagePickerService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  Future<XFile?> pickImageToTemp({
    required ImageSource source,
    ImagePickerOverride? pickerOverride,
  }) async {
    final picked = pickerOverride != null
        ? await pickerOverride(source)
        : await _picker.pickImage(source: source);
    if (picked == null) {
      return null;
    }

    final tempDirectory = await Directory.systemTemp.createTemp(
      'laqta_image_picker_',
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
      mimeType: picked.mimeType ?? _inferImageMimeType(fileName),
    );
  }

  String _safeFileName(XFile file) {
    final rawName = file.name.trim().isNotEmpty
        ? file.name.trim()
        : file.path.split(RegExp(r'[\\/]')).last;
    final sanitized = rawName
        .replaceAll(RegExp(r'[^a-zA-Z0-9._-]+'), '_')
        .replaceAll(RegExp(r'_+'), '_');
    if (_hasSupportedImageExtension(sanitized)) {
      return sanitized;
    }

    final extension = _extensionFromMimeType(file.mimeType) ?? 'jpg';
    final base = sanitized.replaceAll(RegExp(r'\.+$'), '');
    return '${base.isEmpty ? 'image' : base}.$extension';
  }

  bool _hasSupportedImageExtension(String fileName) {
    final lower = fileName.toLowerCase();
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.webp');
  }

  String? _extensionFromMimeType(String? mimeType) {
    switch (mimeType?.toLowerCase()) {
      case 'image/png':
        return 'png';
      case 'image/webp':
        return 'webp';
      case 'image/jpg':
      case 'image/jpeg':
        return 'jpg';
    }
    return null;
  }

  String _inferImageMimeType(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.png')) {
      return 'image/png';
    }
    if (lower.endsWith('.webp')) {
      return 'image/webp';
    }
    return 'image/jpeg';
  }
}
