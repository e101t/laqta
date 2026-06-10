import 'package:laqta/core/utils/legacy_data_compat.dart';

class TrustStatsDto {
  final String photographerId;
  final int reviewCount;
  final double sumQuality;
  final double sumCommunication;
  final double sumOnTime;
  final double sumDelivery;
  final int completedBookings;
  final int canceledByPhotographer;
  final int disputesCount;
  final DateTime updatedAt;

  const TrustStatsDto({
    required this.photographerId,
    required this.reviewCount,
    required this.sumQuality,
    required this.sumCommunication,
    required this.sumOnTime,
    required this.sumDelivery,
    required this.completedBookings,
    required this.canceledByPhotographer,
    required this.disputesCount,
    required this.updatedAt,
  });

  factory TrustStatsDto.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return TrustStatsDto(
      photographerId: doc.id,
      reviewCount: _readInt(data, 'reviewCount'),
      sumQuality: _readDouble(data, 'sumQuality'),
      sumCommunication: _readDouble(data, 'sumCommunication'),
      sumOnTime: _readDouble(data, 'sumOnTime'),
      sumDelivery: _readDouble(data, 'sumDelivery'),
      completedBookings: _readInt(data, 'completedBookings'),
      canceledByPhotographer: _readInt(data, 'canceledByPhotographer'),
      disputesCount: _readInt(data, 'disputesCount'),
      updatedAt: _readDateTime(data['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'photographerId': photographerId,
      'reviewCount': reviewCount,
      'sumQuality': sumQuality,
      'sumCommunication': sumCommunication,
      'sumOnTime': sumOnTime,
      'sumDelivery': sumDelivery,
      'completedBookings': completedBookings,
      'canceledByPhotographer': canceledByPhotographer,
      'disputesCount': disputesCount,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
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
