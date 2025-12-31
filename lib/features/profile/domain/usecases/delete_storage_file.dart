import 'package:luqta/core/domain/result/result.dart';
import '../repositories/profile_repository.dart';

class DeleteStorageFile {
  final ProfileRepository _repository;

  const DeleteStorageFile(this._repository);

  Future<Result<void>> call(String url) {
    return _repository.deleteFileByUrl(url);
  }
}
