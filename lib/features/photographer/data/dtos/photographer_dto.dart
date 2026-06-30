class PhotographerDetailsDto {
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

  const PhotographerDetailsDto({
    required this.id,
    required this.specialties,
    required this.governorates,
    required this.rate,
    required this.reviewsCount,
    required this.basePrice,
    required this.currency,
    required this.bio,
    this.instagram,
    this.tiktok,
    required this.isVerified,
    this.verifiedAt,
    required this.updatedAt,
  });

  factory PhotographerDetailsDto.fromJson(Map<String, dynamic> json) {
    return PhotographerDetailsDto(
      id: _readString(json, 'id'),
      specialties: _readStringList(json['specialties']),
      governorates: _readStringList(json['governorates'] ?? json['coverageAreas']),
      rate: _readDouble(json, 'rate') != 0
          ? _readDouble(json, 'rate')
          : _readDouble(json, 'ratingAverage'),
      reviewsCount: _readInt(json, 'reviewsCount') != 0
          ? _readInt(json, 'reviewsCount')
          : _readInt(json, 'ratingCount'),
      basePrice: _readDouble(json, 'basePrice'),
      currency: _readString(json, 'currency', fallback: 'IQD'),
      bio: _readString(json, 'bio'),
      instagram: _readNullableString(json, 'instagram') ??
          _readNullableString(json, 'instagramHandle'),
      tiktok: _readNullableString(json, 'tiktok'),
      isVerified: _readBool(json, 'isVerified') || _readBool(json, 'verified'),
      verifiedAt: _readNullableDateTime(json['verifiedAt']),
      updatedAt: _readDateTime(json['updatedAt']),
    );
  }

  static String _readString(
    Map<String, dynamic> data,
    String key, {
    String fallback = '',
  }) {
    final value = data[key];
    return value is String ? value : fallback;
  }

  static String? _readNullableString(Map<String, dynamic> data, String key) {
    final value = data[key];
    return value is String ? value : null;
  }

  static List<String> _readStringList(dynamic value) {
    if (value is List) return value.whereType<String>().toList();
    return const [];
  }

  static double _readDouble(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  static int _readInt(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static bool _readBool(Map<String, dynamic> data, String key) {
    final value = data[key];
    return value is bool ? value : false;
  }

  static DateTime _readDateTime(dynamic value) {
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    if (value is DateTime) return value;
    return DateTime.now();
  }

  static DateTime? _readNullableDateTime(dynamic value) {
    if (value is String) return DateTime.tryParse(value);
    if (value is DateTime) return value;
    return null;
  }
}

class PhotographerReviewDto {
  final String id;
  final String bookingId;
  final String reviewerId;
  final String targetId;
  final int rating;
  final int qualityRating;
  final int communicationRating;
  final int onTimeRating;
  final int deliverySpeedRating;
  final bool? recommend;
  final String? comment;
  final DateTime createdAt;

  const PhotographerReviewDto({
    required this.id,
    required this.bookingId,
    required this.reviewerId,
    required this.targetId,
    required this.rating,
    required this.qualityRating,
    required this.communicationRating,
    required this.onTimeRating,
    required this.deliverySpeedRating,
    this.recommend,
    this.comment,
    required this.createdAt,
  });

  factory PhotographerReviewDto.fromJson(Map<String, dynamic> json) {
    return PhotographerReviewDto(
      id: _readString(json, 'id'),
      bookingId: _readString(json, 'bookingId'),
      reviewerId: _readString(json, 'reviewerId'),
      targetId: _readString(json, 'targetId'),
      rating: _readInt(json, 'rating'),
      qualityRating: _readInt(json, 'qualityRating'),
      communicationRating: _readInt(json, 'communicationRating'),
      onTimeRating: _readInt(json, 'onTimeRating'),
      deliverySpeedRating: _readInt(json, 'deliverySpeedRating'),
      recommend: json['recommend'] is bool ? json['recommend'] as bool : null,
      comment: _readNullableString(json, 'comment'),
      createdAt: _readDateTime(json['createdAt']),
    );
  }

  static String _readString(
    Map<String, dynamic> data,
    String key, {
    String fallback = '',
  }) {
    final value = data[key];
    return value is String ? value : fallback;
  }

  static String? _readNullableString(Map<String, dynamic> data, String key) {
    final value = data[key];
    return value is String ? value : null;
  }

  static int _readInt(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static DateTime _readDateTime(dynamic value) {
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    if (value is DateTime) return value;
    return DateTime.now();
  }
}
