import 'package:luqta/core/domain/result/result.dart';
import '../repositories/trust_repository.dart';

class IncrementCanceledByPhotographer {
  final TrustRepository _repository;

  const IncrementCanceledByPhotographer(this._repository);

  Future<Result<void>> call({
    required String bookingId,
    required String photographerId,
  }) {
    return _repository.incrementCanceledByPhotographer(
      bookingId: bookingId,
      photographerId: photographerId,
    );
  }
}
