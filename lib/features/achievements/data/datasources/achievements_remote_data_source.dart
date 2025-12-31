import 'package:luqta/features/achievements/data/dtos/user_achievement_dto.dart';

abstract class AchievementsRemoteDataSource {
  Future<List<UserAchievementDto>> getUserAchievements(String userId);
}
