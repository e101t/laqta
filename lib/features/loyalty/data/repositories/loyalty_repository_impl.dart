import 'package:luqta/core/domain/failures/failure.dart';
import 'package:luqta/core/domain/result/result.dart';
import 'package:luqta/features/loyalty/data/datasources/loyalty_remote_data_source.dart';
import 'package:luqta/features/loyalty/data/mappers/loyalty_mapper.dart';
import 'package:luqta/features/loyalty/domain/entities/loyalty_points.dart';
import 'package:luqta/features/loyalty/domain/repositories/loyalty_repository.dart';

class LoyaltyRepositoryImpl implements LoyaltyRepository {
  final LoyaltyRemoteDataSource _remoteDataSource;

  const LoyaltyRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<LoyaltyPoints>> getOrCreateLoyaltyPoints({
    required String userId,
  }) async {
    try {
      final dto = await _remoteDataSource.getLoyaltyPoints(userId);
      if (dto != null) {
        return Result.success(LoyaltyMapper.toDomain(dto));
      }

      final defaultPoints = LoyaltyPoints(
        userId: userId,
        totalPoints: 0,
        availablePoints: 0,
        usedPoints: 0,
        tier: 'bronze',
        lastUpdated: DateTime.now(),
        transactions: const [],
      );
      await _remoteDataSource.saveLoyaltyPoints(
        userId,
        LoyaltyMapper.toDto(defaultPoints),
      );

      return Result.success(defaultPoints);
    } catch (_) {
      return Result.failure(
        const Failure(message: 'Failed to load loyalty points'),
      );
    }
  }
}
