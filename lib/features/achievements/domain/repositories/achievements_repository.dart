import 'package:laqta/core/domain/result/result.dart';
import 'package:laqta/core/models/achievement_model.dart';

abstract class AchievementsRepository {
  Future<Result<List<UserAchievement>>> getUserAchievements({
    required String userId,
  });
}
