import 'package:luqta/core/domain/result/result.dart';
import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

class GetUserProfile {
  final ProfileRepository _repository;

  const GetUserProfile(this._repository);

  Future<Result<UserProfile>> call({required String userId}) {
    return _repository.getUserProfile(userId: userId);
  }
}
