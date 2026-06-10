import 'package:laqta/core/domain/result/result.dart';
import '../entities/request_offer.dart';
import '../repositories/requests_repository.dart';

class GetOffersForRequest {
  final RequestsRepository _repository;

  const GetOffersForRequest(this._repository);

  Future<Result<List<RequestOffer>>> call(String requestId) {
    return _repository.getOffersForRequest(requestId);
  }
}
