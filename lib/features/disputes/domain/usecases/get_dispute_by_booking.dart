import 'package:laqta/core/domain/result/result.dart';
import '../entities/dispute.dart';
import '../repositories/disputes_repository.dart';

class GetDisputeByBooking {
  final DisputesRepository _repository;

  const GetDisputeByBooking(this._repository);

  Future<Result<Dispute?>> call(String bookingId) {
    return _repository.getDisputeByBooking(bookingId);
  }
}
