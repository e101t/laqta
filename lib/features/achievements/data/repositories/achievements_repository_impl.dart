import 'package:laqta/core/domain/failures/failure.dart';
import 'package:laqta/core/domain/result/result.dart';
import 'package:laqta/core/models/achievement_model.dart';
import 'package:laqta/features/achievements/data/datasources/achievements_remote_data_source.dart';
import 'package:laqta/features/achievements/data/mappers/achievement_mapper.dart';
import 'package:laqta/features/achievements/domain/repositories/achievements_repository.dart';

class AchievementsRepositoryImpl implements AchievementsRepository {
  final AchievementsRemoteDataSource _remoteDataSource;

  const AchievementsRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<List<UserAchievement>>> getUserAchievements({
    required String userId,
  }) async {
    try {
      final dtos = await _remoteDataSource.getUserAchievements(userId);
      final achievements = dtos.map(AchievementMapper.toDomain).toList();
      return Result.success(achievements);
    } catch (_) {
      return Result.failure(
        const Failure(message: 'Failed to load achievements'),
      );
    }
  }
}
