import 'package:laqta/core/domain/result/result.dart';
import 'package:laqta/core/models/achievement_model.dart';
import '../repositories/achievements_repository.dart';

class GetUserAchievements {
  final AchievementsRepository _repository;

  const GetUserAchievements(this._repository);

  Future<Result<List<UserAchievement>>> call({required String userId}) {
    return _repository.getUserAchievements(userId: userId);
  }
}
