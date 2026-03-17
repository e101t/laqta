import 'package:laqta/core/domain/result/result.dart';
import '../repositories/requests_repository.dart';

class UpdateRequest {
  final RequestsRepository _repository;

  const UpdateRequest(this._repository);

  Future<Result<void>> call({
    required String requestId,
    required Map<String, dynamic> updates,
  }) {
    return _repository.updateRequest(requestId: requestId, updates: updates);
  }
}
