import 'package:laqta/core/domain/result/result.dart';
import '../entities/user_profile_update.dart';
import '../repositories/profile_repository.dart';

class SaveBasicInfo {
  final ProfileRepository _repository;

  const SaveBasicInfo(this._repository);

  Future<Result<void>> call({
    required String userId,
    required BasicInfoData data,
  }) {
    return _repository.saveBasicInfo(userId: userId, data: data);
  }
}
