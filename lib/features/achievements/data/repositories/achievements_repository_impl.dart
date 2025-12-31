import 'package:luqta/core/domain/failures/failure.dart';
import 'package:luqta/core/domain/result/result.dart';
import 'package:luqta/core/models/achievement_model.dart';
import 'package:luqta/features/achievements/data/datasources/achievements_remote_data_source.dart';
import 'package:luqta/features/achievements/data/mappers/achievement_mapper.dart';
import 'package:luqta/features/achievements/domain/repositories/achievements_repository.dart';

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
