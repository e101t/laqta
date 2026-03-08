import 'package:luqta/core/domain/result/result.dart';
import '../entities/photo_request.dart';
import '../repositories/requests_repository.dart';

class CreateRequest {
  final RequestsRepository _repository;

  const CreateRequest(this._repository);

  Future<Result<void>> call(PhotoRequest request) {
    return _repository.createRequest(request);
  }
}
