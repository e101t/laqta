class TrustStats {
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

  const TrustStats({
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

  double get avgQuality => reviewCount == 0 ? 0 : sumQuality / reviewCount;
  double get avgCommunication =>
      reviewCount == 0 ? 0 : sumCommunication / reviewCount;
  double get avgOnTime => reviewCount == 0 ? 0 : sumOnTime / reviewCount;
  double get avgDelivery => reviewCount == 0 ? 0 : sumDelivery / reviewCount;

  TrustStats copyWith({
    int? reviewCount,
    double? sumQuality,
    double? sumCommunication,
    double? sumOnTime,
    double? sumDelivery,
    int? completedBookings,
    int? canceledByPhotographer,
    int? disputesCount,
    DateTime? updatedAt,
  }) {
    return TrustStats(
      photographerId: photographerId,
      reviewCount: reviewCount ?? this.reviewCount,
      sumQuality: sumQuality ?? this.sumQuality,
      sumCommunication: sumCommunication ?? this.sumCommunication,
      sumOnTime: sumOnTime ?? this.sumOnTime,
      sumDelivery: sumDelivery ?? this.sumDelivery,
      completedBookings: completedBookings ?? this.completedBookings,
      canceledByPhotographer:
          canceledByPhotographer ?? this.canceledByPhotographer,
      disputesCount: disputesCount ?? this.disputesCount,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
