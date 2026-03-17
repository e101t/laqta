import 'package:laqta/core/domain/result/result.dart';
import '../entities/request_offer.dart';
import '../repositories/requests_repository.dart';

class GetMyOffers {
  final RequestsRepository _repository;

  const GetMyOffers(this._repository);

  Future<Result<List<RequestOffer>>> call({required String photographerId}) {
    return _repository.getMyOffers(photographerId: photographerId);
  }
}
