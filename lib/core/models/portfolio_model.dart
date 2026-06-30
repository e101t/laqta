import 'package:laqta/core/services/backend_config.dart';
import 'package:laqta/core/utils/firestore_parsers.dart';

class PortfolioModel {
  final String id;
  final String photographerId;
  final List<PortfolioImage> images;

  PortfolioModel({
    required this.id,
    required this.photographerId,
    required this.images,
  });

  Map<String, dynamic> toJson() {
    return {
      'photographerId': photographerId,
      'images': images.map((img) => img.toMap()).toList(),
    };
  }
}

class PortfolioImage {
  final String? mediaId;
  final String url;
  final int? width;
  final int? height;
  final DateTime createdAt;

  PortfolioImage({this.mediaId, required this.url, this.width, this.height, required this.createdAt});

  factory PortfolioImage.fromMap(Map<String, dynamic> map) {
    final mediaId = readNullableString(map, 'mediaId');
    return PortfolioImage(
      mediaId: mediaId,
      url: mediaId != null && mediaId.isNotEmpty
          ? BackendConfig.mediaContentUrl(mediaId)
          : readString(map, 'url'),
      width: readNullableInt(map, 'w'),
      height: readNullableInt(map, 'h'),
      createdAt: readDateTime(map, 'createdAt'),
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
}
