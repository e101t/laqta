import 'package:luqta/core/domain/result/result.dart';
import '../repositories/requests_repository.dart';

class UploadRequestReference {
  final RequestsRepository _repository;

  const UploadRequestReference(this._repository);

  Future<Result<String>> call({
    required String requestId,
    required String filePath,
  }) {
    return _repository.uploadReferenceImage(
      requestId: requestId,
      filePath: filePath,
    );
  }
}
