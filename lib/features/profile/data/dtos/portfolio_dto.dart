import 'package:cloud_firestore/cloud_firestore.dart';

class PortfolioDto {
  final String id;
  final String photographerId;
  final List<PortfolioImageDto> images;

  const PortfolioDto({
    required this.id,
    required this.photographerId,
    required this.images,
  });

  factory PortfolioDto.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    final imagesRaw = data['images'];
    final rawImages = imagesRaw is List
        ? imagesRaw.whereType<Map<dynamic, dynamic>>()
        : const <Map<dynamic, dynamic>>[];

    return PortfolioDto(
      id: doc.id,
      photographerId: _readString(data, 'photographerId'),
      images: rawImages
          .map(
            (img) => PortfolioImageDto.fromMap(Map<String, dynamic>.from(img)),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'photographerId': photographerId,
      'images': images.map((img) => img.toMap()).toList(),
    };
  }

  static String _readString(
    Map<String, dynamic> data,
    String key, {
    String fallback = '',
  }) {
    final value = data[key];
    if (value is String) {
      return value;
    }
    return fallback;
  }
}

class PortfolioImageDto {
  final String url;
  final int? width;
  final int? height;
  final DateTime createdAt;

  const PortfolioImageDto({
    required this.url,
    this.width,
    this.height,
    required this.createdAt,
  });

  factory PortfolioImageDto.fromMap(Map<String, dynamic> map) {
    return PortfolioImageDto(
      url: map['url'] ?? '',
      width: map['w'],
      height: map['h'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'url': url,
      'w': width,
      'h': height,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
