import 'package:laqta/core/domain/result/result.dart';
import '../entities/trust_stats.dart';

abstract class TrustRepository {
  Future<Result<TrustStats?>> getTrustStats(String photographerId);

  Future<Result<void>> incrementReviewStats({
    required String bookingId,
    required String photographerId,
    required double qualityRating,
    required double communicationRating,
    required double onTimeRating,
    required double deliverySpeedRating,
  });

  Future<Result<void>> incrementCompletedBookings({
    required String bookingId,
    required String photographerId,
  });

  Future<Result<void>> incrementCanceledByPhotographer({
    required String bookingId,
    required String photographerId,
  });

  Future<Result<void>> incrementDisputesCount({
    required String bookingId,
    required String photographerId,
  });
}
