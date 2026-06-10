import '../dtos/trust_stats_dto.dart';

abstract class TrustRemoteDataSource {
  Future<TrustStatsDto?> getTrustStats(String photographerId);

  Future<void> incrementReviewStats({
    required String bookingId,
    required String photographerId,
    required double qualityRating,
    required double communicationRating,
    required double onTimeRating,
    required double deliverySpeedRating,
  });

  Future<void> incrementCompletedBookings({
    required String bookingId,
    required String photographerId,
  });

  Future<void> incrementCanceledByPhotographer({
    required String bookingId,
    required String photographerId,
  });

  Future<void> incrementDisputesCount({
    required String bookingId,
    required String photographerId,
  });
}
