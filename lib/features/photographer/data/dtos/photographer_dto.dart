import 'package:laqta/core/utils/legacy_data_compat.dart';

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

  factory PhotographerDetailsDto.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return PhotographerDetailsDto(
      id: doc.id,
      specialties: _readStringList(data['specialties']),
      governorates: _readStringList(data['governorates']),
      rate: _readDouble(data, 'rate'),
      reviewsCount: _readInt(data, 'reviewsCount'),
      basePrice: _readDouble(data, 'basePrice'),
      currency: _readString(data, 'currency', fallback: 'IQD'),
      bio: _readString(data, 'bio'),
      instagram: _readNullableString(data, 'instagram'),
      tiktok: _readNullableString(data, 'tiktok'),
      isVerified: _readBool(data, 'isVerified'),
      verifiedAt: _readNullableDateTime(data['verifiedAt']),
      updatedAt: _readDateTime(data['updatedAt']),
    );
  }

  static String _readString(
    Map<String, dynamic> data,
    String key, {
    String fallback = '',
  }) {
    final value = data[key];
    if (value is String) {
      return value;
    }
    return fallback;
  }

  static String? _readNullableString(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is String) {
      return value;
    }
    return null;
  }

  static List<String> _readStringList(dynamic value) {
    if (value is List) {
      return value.whereType<String>().toList();
    }
    return <String>[];
  }

  static double _readDouble(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is double) {
      return value;
    }
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value) ?? 0;
    }
    return 0;
  }

  static int _readInt(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  static bool _readBool(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is bool) {
      return value;
    }
    return false;
  }

  static DateTime _readDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    return DateTime.now();
  }

  static DateTime? _readNullableDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
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

  factory PhotographerReviewDto.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return PhotographerReviewDto(
      id: doc.id,
      bookingId: _readString(data, 'bookingId'),
      reviewerId: _readString(data, 'reviewerId'),
      targetId: _readString(data, 'targetId'),
      rating: _readInt(data, 'rating'),
      qualityRating: _readInt(data, 'qualityRating'),
      communicationRating: _readInt(data, 'communicationRating'),
      onTimeRating: _readInt(data, 'onTimeRating'),
      deliverySpeedRating: _readInt(data, 'deliverySpeedRating'),
      recommend: data['recommend'] is bool ? data['recommend'] as bool : null,
      comment: _readNullableString(data, 'comment'),
      createdAt: _readDateTime(data['createdAt']),
    );
  }

  static String _readString(
    Map<String, dynamic> data,
    String key, {
    String fallback = '',
  }) {
    final value = data[key];
    if (value is String) {
      return value;
    }
    return fallback;
  }

  static String? _readNullableString(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is String) {
      return value;
    }
    return null;
  }

  static int _readInt(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  static DateTime _readDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    return DateTime.now();
  }
}
