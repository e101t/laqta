import '../repositories/requests_repository.dart';

class GenerateRequestId {
  final RequestsRepository _repository;

  const GenerateRequestId(this._repository);

  String call() => _repository.generateRequestId();
}
