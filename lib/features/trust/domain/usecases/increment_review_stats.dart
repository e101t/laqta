import 'package:laqta/core/domain/result/result.dart';
import '../repositories/trust_repository.dart';

class IncrementReviewStats {
  final TrustRepository _repository;

  const IncrementReviewStats(this._repository);

  Future<Result<void>> call({
    required String bookingId,
    required String photographerId,
    required double qualityRating,
    required double communicationRating,
    required double onTimeRating,
    required double deliverySpeedRating,
  }) {
    return _repository.incrementReviewStats(
      bookingId: bookingId,
      photographerId: photographerId,
      qualityRating: qualityRating,
      communicationRating: communicationRating,
      onTimeRating: onTimeRating,
      deliverySpeedRating: deliverySpeedRating,
    );
  }
}
