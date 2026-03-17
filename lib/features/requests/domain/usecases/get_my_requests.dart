import 'package:laqta/core/domain/result/result.dart';
import '../entities/photo_request.dart';
import '../repositories/requests_repository.dart';

class GetMyRequests {
  final RequestsRepository _repository;

  const GetMyRequests(this._repository);

  Future<Result<List<PhotoRequest>>> call({required String clientId}) {
    return _repository.getMyRequests(clientId: clientId);
  }
}
