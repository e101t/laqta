import 'package:laqta/core/services/backend_config.dart';

class PortfolioDto {
  final String id;
  final String photographerId;
  final List<PortfolioImageDto> images;

  const PortfolioDto({
    required this.id,
    required this.photographerId,
    required this.images,
  });

  Map<String, dynamic> toMap() {
    return {
      'photographerId': photographerId,
      'images': images.map((img) => img.toMap()).toList(),
    };
  }
}

class PortfolioImageDto {
  final String? mediaId;
  final String url;
  final int? width;
  final int? height;
  final DateTime createdAt;

  const PortfolioImageDto({
    this.mediaId,
    required this.url,
    this.width,
    this.height,
    required this.createdAt,
  });

  factory PortfolioImageDto.fromMap(Map<String, dynamic> map) {
    return PortfolioImageDto(
      mediaId: _readNullableString(map, 'mediaId'),
      url: _resolveUrl(map),
      width: _readNullableInt(map, 'w'),
      height: _readNullableInt(map, 'h'),
      createdAt: _readDateTime(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (mediaId != null && mediaId!.isNotEmpty) 'mediaId': mediaId,
      'url': url,
      'w': width,
      'h': height,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static String _readString(Map<String, dynamic> data, String key, {String fallback = ''}) {
    final value = data[key];
    if (value is String) return value;
    return fallback;
  }

  static String? _readNullableString(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is String) return value;
    return null;
  }

  static String _resolveUrl(Map<String, dynamic> data) {
    final mediaId = _readNullableString(data, 'mediaId');
    if (mediaId != null && mediaId.isNotEmpty) {
      return BackendConfig.mediaContentUrl(mediaId);
    }
    return _readString(data, 'url');
  }

  static int? _readNullableInt(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static DateTime _readDateTime(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }
}
