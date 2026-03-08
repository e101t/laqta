import 'package:luqta/core/domain/result/result.dart';
import 'package:luqta/features/booking/domain/entities/booking.dart';
import '../entities/photo_request.dart';
import '../entities/request_offer.dart';
import '../repositories/requests_repository.dart';

class AcceptOffer {
  final RequestsRepository _repository;

  const AcceptOffer(this._repository);

  Future<Result<void>> call({
    required PhotoRequest request,
    required RequestOffer offer,
    required Booking booking,
  }) {
    return _repository.acceptOffer(
      request: request,
      offer: offer,
      booking: booking,
    );
  }
}
