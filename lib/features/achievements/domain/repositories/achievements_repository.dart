import 'package:luqta/core/domain/result/result.dart';
import 'package:luqta/core/models/achievement_model.dart';

abstract class AchievementsRepository {
  Future<Result<List<UserAchievement>>> getUserAchievements({
    required String userId,
  });
}
