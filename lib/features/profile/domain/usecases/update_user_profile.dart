import 'package:laqta/core/domain/result/result.dart';
import '../entities/user_profile_update.dart';
import '../repositories/profile_repository.dart';

class UpdateUserProfile {
  final ProfileRepository _repository;

  const UpdateUserProfile(this._repository);

  Future<Result<void>> call({
    required String userId,
    required UserProfileUpdate update,
  }) {
    return _repository.updateUserProfile(userId: userId, update: update);
  }
}
