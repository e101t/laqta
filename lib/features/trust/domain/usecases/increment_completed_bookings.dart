import 'package:luqta/core/domain/result/result.dart';
import '../repositories/trust_repository.dart';

class IncrementCompletedBookings {
  final TrustRepository _repository;

  const IncrementCompletedBookings(this._repository);

  Future<Result<void>> call({
    required String bookingId,
    required String photographerId,
  }) {
    return _repository.incrementCompletedBookings(
      bookingId: bookingId,
      photographerId: photographerId,
    );
  }
}
