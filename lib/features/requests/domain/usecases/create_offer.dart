import 'package:laqta/core/domain/result/result.dart';
import '../entities/request_offer.dart';
import '../repositories/requests_repository.dart';

class CreateOffer {
  final RequestsRepository _repository;

  const CreateOffer(this._repository);

  Future<Result<void>> call(RequestOffer offer) {
    return _repository.createOffer(offer);
  }
}
