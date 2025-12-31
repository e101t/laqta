class Portfolio {
  final String id;
  final String photographerId;
  final List<PortfolioImage> images;

  const Portfolio({
    required this.id,
    required this.photographerId,
    required this.images,
  });
}

class PortfolioImage {
  final String url;
  final int? width;
  final int? height;
  final DateTime createdAt;

  const PortfolioImage({
    required this.url,
    this.width,
    this.height,
    required this.createdAt,
  });
}
