class PhotographerDetails {
  final String id;
  final List<String> specialties;
  final List<String> governorates;
  final double rate;
  final int reviewsCount;
  final double basePrice;
  final String currency;
  final String bio;
  final String? instagram;
  final String? tiktok;
  final bool isVerified;
  final DateTime? verifiedAt;
  final DateTime updatedAt;

  const PhotographerDetails({
    required this.id,
    required this.specialties,
    required this.governorates,
    this.rate = 0.0,
    this.reviewsCount = 0,
    required this.basePrice,
    this.currency = 'IQD',
    required this.bio,
    this.instagram,
    this.tiktok,
    this.isVerified = false,
    this.verifiedAt,
    required this.updatedAt,
  });

  bool get isTopRated => rate >= 4.7;
}
