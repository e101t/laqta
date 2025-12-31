import 'package:cloud_firestore/cloud_firestore.dart';

class PhotographerModel {
  final String uid;
  final List<String> specialties;
  final List<String> governorates;
  final double rate; // 0-5
  final int reviewsCount;
  final double basePrice;
  final String currency; // IQD
  final String bio;
  final String? instagram;
  final String? tiktok;
  final GeoPoint? geo;
  final bool isVerified; // Verified badge
  final DateTime? verifiedAt; // Verification date
  final DateTime updatedAt;

  // Getter for compatibility - same as 'rate'
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
    this.geo,
    this.isVerified = false,
    this.verifiedAt,
    required this.updatedAt,
  });

  factory PhotographerModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PhotographerModel(
      uid: doc.id,
      specialties: List<String>.from(data['specialties'] ?? []),
      governorates: List<String>.from(data['governorates'] ?? []),
      rate: (data['rate'] ?? 0.0).toDouble(),
      reviewsCount: data['reviewsCount'] ?? 0,
      basePrice: (data['basePrice'] ?? 0.0).toDouble(),
      currency: data['currency'] ?? 'IQD',
      bio: data['bio'] ?? '',
      instagram: data['instagram'],
      tiktok: data['tiktok'],
      geo: data['geo'],
      isVerified: data['isVerified'] ?? false,
      verifiedAt: (data['verifiedAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
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
      'geo': geo,
      'isVerified': isVerified,
      'verifiedAt': verifiedAt != null ? Timestamp.fromDate(verifiedAt!) : null,
      'updatedAt': Timestamp.fromDate(updatedAt),
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
    GeoPoint? geo,
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
      geo: geo ?? this.geo,
      isVerified: isVerified ?? this.isVerified,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
