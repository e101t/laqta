import 'package:laqta/core/domain/result/result.dart';
import '../entities/photo_request.dart';
import '../repositories/requests_repository.dart';

class GetOpenRequests {
  final RequestsRepository _repository;

  const GetOpenRequests(this._repository);

  Future<Result<List<PhotoRequest>>> call({String? governorate}) {
    return _repository.getOpenRequests(governorate: governorate);
  }
}
