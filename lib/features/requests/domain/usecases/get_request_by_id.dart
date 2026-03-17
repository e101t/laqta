import 'package:laqta/core/domain/result/result.dart';
import '../entities/photo_request.dart';
import '../repositories/requests_repository.dart';

class GetRequestById {
  final RequestsRepository _repository;

  const GetRequestById(this._repository);

  Future<Result<PhotoRequest>> call(String requestId) {
    return _repository.getRequestById(requestId);
  }
}
