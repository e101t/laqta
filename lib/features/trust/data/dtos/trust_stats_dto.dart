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

  factory TrustStatsDto.fromJson(Map<String, dynamic> json) {
    return TrustStatsDto(
      photographerId: _readString(json, 'photographerId'),
      reviewCount: _readInt(json, 'reviewCount'),
      sumQuality: _readDouble(json, 'sumQuality'),
      sumCommunication: _readDouble(json, 'sumCommunication'),
      sumOnTime: _readDouble(json, 'sumOnTime'),
      sumDelivery: _readDouble(json, 'sumDelivery'),
      completedBookings: _readInt(json, 'completedBookings'),
      canceledByPhotographer: _readInt(json, 'canceledByPhotographer'),
      disputesCount: _readInt(json, 'disputesCount'),
      updatedAt: _readDateTime(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
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
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  static int _readInt(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _readDouble(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  static String _readString(
    Map<String, dynamic> data,
    String key, {
    String fallback = '',
  }) {
    final value = data[key];
    return value is String ? value : fallback;
  }

  static DateTime _readDateTime(dynamic value) {
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    if (value is DateTime) return value;
    return DateTime.now();
  }
}
