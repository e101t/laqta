import 'package:laqta/core/models/achievement_model.dart';
import 'package:laqta/features/achievements/data/dtos/user_achievement_dto.dart';

class AchievementMapper {
  static UserAchievement toDomain(UserAchievementDto dto) {
    return UserAchievement(
      userId: dto.userId,
      achievementId: dto.achievementId,
      currentProgress: dto.currentProgress,
      isUnlocked: dto.isUnlocked,
      unlockedAt: dto.unlockedAt,
    );
  }
}
