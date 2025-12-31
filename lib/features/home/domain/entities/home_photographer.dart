class HomePhotographer {
  final String id;
  final String displayName;
  final String? photoUrl;
  final String primaryGovernorate;
  final List<String> specialties;
  final double rating;
  final int reviewsCount;
  final double basePrice;
  final String? username;
  final String? gender;
  final int? age;
  final bool isTopRated;

  const HomePhotographer({
    required this.id,
    required this.displayName,
    this.photoUrl,
    required this.primaryGovernorate,
    required this.specialties,
    required this.rating,
    required this.reviewsCount,
    required this.basePrice,
    this.username,
    this.gender,
    this.age,
    required this.isTopRated,
  });
}
