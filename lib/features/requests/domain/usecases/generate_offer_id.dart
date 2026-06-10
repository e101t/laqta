import '../repositories/requests_repository.dart';

class GenerateOfferId {
  final RequestsRepository _repository;

  const GenerateOfferId(this._repository);

  String call() => _repository.generateOfferId();
}
