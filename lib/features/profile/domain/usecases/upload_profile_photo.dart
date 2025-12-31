import 'package:luqta/core/domain/result/result.dart';
import '../repositories/profile_repository.dart';

class UploadProfilePhoto {
  final ProfileRepository _repository;

  const UploadProfilePhoto(this._repository);

  Future<Result<String>> call({
    required String userId,
    required String filePath,
  }) {
    return _repository.uploadProfilePhoto(userId: userId, filePath: filePath);
  }
}
