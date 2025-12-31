import 'package:cloud_firestore/cloud_firestore.dart';

class PortfolioModel {
  final String id;
  final String photographerId;
  final List<PortfolioImage> images;

  PortfolioModel({
    required this.id,
    required this.photographerId,
    required this.images,
  });

  factory PortfolioModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final imagesList = data['images'] as List<dynamic>? ?? [];
    return PortfolioModel(
      id: doc.id,
      photographerId: data['photographerId'] ?? '',
      images: imagesList
          .map((img) => PortfolioImage.fromMap(img as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'photographerId': photographerId,
      'images': images.map((img) => img.toMap()).toList(),
    };
  }
}

class PortfolioImage {
  final String url;
  final int? width;
  final int? height;
  final DateTime createdAt;

  PortfolioImage({
    required this.url,
    this.width,
    this.height,
    required this.createdAt,
  });

  factory PortfolioImage.fromMap(Map<String, dynamic> map) {
    return PortfolioImage(
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
