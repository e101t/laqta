import 'package:flutter/material.dart';

ImageProvider? resolveImageProvider(String? source) {
  if (source == null) return null;
  final trimmed = source.trim();
  if (trimmed.isEmpty) return null;
  if (trimmed.startsWith('assets/')) {
    return AssetImage(trimmed);
  }
  if (trimmed.startsWith('asset:')) {
    return AssetImage(trimmed.replaceFirst('asset:', ''));
  }
  return NetworkImage(trimmed);
}
