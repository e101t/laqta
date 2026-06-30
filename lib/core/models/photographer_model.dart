import 'package:laqta/core/utils/firestore_parsers.dart';

class PhotographerModel {
  final String uid;
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

  double get rating => rate;

  PhotographerModel({
    required this.uid,
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

  factory PhotographerModel.fromMap(String id, Map<String, dynamic> data) {
    return PhotographerModel(
      uid: id,
      specialties: readStringList(data, 'specialties'),
      governorates: readStringList(data, 'governorates'),
      rate: readDouble(data, 'rate'),
      reviewsCount: readInt(data, 'reviewsCount'),
      basePrice: readDouble(data, 'basePrice'),
      currency: readString(data, 'currency', defaultValue: 'IQD'),
      bio: readString(data, 'bio'),
      instagram: readNullableString(data, 'instagram'),
      tiktok: readNullableString(data, 'tiktok'),
      isVerified: readBool(data, 'isVerified'),
      verifiedAt: readDate(data['verifiedAt']),
      updatedAt: readDateTime(data, 'updatedAt'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'specialties': specialties,
      'governorates': governorates,
      'rate': rate,
      'reviewsCount': reviewsCount,
      'basePrice': basePrice,
      'currency': currency,
      'bio': bio,
      'instagram': instagram,
      'tiktok': tiktok,
      'isVerified': isVerified,
      'verifiedAt': verifiedAt?.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  bool get isTopRated => rate >= 4.7;

  PhotographerModel copyWith({
    List<String>? specialties,
    List<String>? governorates,
    double? rate,
    int? reviewsCount,
    double? basePrice,
    String? currency,
    String? bio,
    String? instagram,
    String? tiktok,
    bool? isVerified,
    DateTime? verifiedAt,
    DateTime? updatedAt,
  }) {
    return PhotographerModel(
      uid: uid,
      specialties: specialties ?? this.specialties,
      governorates: governorates ?? this.governorates,
      rate: rate ?? this.rate,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      basePrice: basePrice ?? this.basePrice,
      currency: currency ?? this.currency,
      bio: bio ?? this.bio,
      instagram: instagram ?? this.instagram,
      tiktok: tiktok ?? this.tiktok,
      isVerified: isVerified ?? this.isVerified,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
