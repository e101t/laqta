import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:luqta/core/utils/firestore_parsers.dart';

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
    final data = firestoreMap(doc.data());
    final rawImages = readMapList(data, 'images');
    return PortfolioModel(
      id: doc.id,
      photographerId: readString(data, 'photographerId'),
      images: rawImages.map(PortfolioImage.fromMap).toList(),
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
      url: readString(map, 'url'),
      width: readNullableInt(map, 'w'),
      height: readNullableInt(map, 'h'),
      createdAt: readDateTime(map, 'createdAt'),
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
