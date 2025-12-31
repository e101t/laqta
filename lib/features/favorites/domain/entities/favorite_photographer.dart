class FavoritePhotographer {
  final String id;
  final String name;
  final String image;
  final List<String> specialties;
  final double rating;
  final int reviewCount;
  final double startingPrice;
  final String governorate;
  final String? username;
  final String? gender;
  final int? age;

  const FavoritePhotographer({
    required this.id,
    required this.name,
    required this.image,
    required this.specialties,
    required this.rating,
    required this.reviewCount,
    required this.startingPrice,
    required this.governorate,
    this.username,
    this.gender,
    this.age,
  });
}
