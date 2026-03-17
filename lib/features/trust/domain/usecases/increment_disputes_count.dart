import 'package:laqta/core/domain/result/result.dart';
import '../repositories/trust_repository.dart';

class IncrementDisputesCount {
  final TrustRepository _repository;

  const IncrementDisputesCount(this._repository);

  Future<Result<void>> call({
    required String bookingId,
    required String photographerId,
  }) {
    return _repository.incrementDisputesCount(
      bookingId: bookingId,
      photographerId: photographerId,
    );
  }
}
