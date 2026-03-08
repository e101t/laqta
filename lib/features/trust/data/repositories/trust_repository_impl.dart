import 'package:luqta/core/domain/failures/failure.dart';
import 'package:luqta/core/domain/result/result.dart';
import 'package:luqta/features/trust/data/datasources/trust_remote_data_source.dart';
import 'package:luqta/features/trust/data/mappers/trust_stats_mapper.dart';
import 'package:luqta/features/trust/domain/entities/trust_stats.dart';
import 'package:luqta/features/trust/domain/repositories/trust_repository.dart';

class TrustRepositoryImpl implements TrustRepository {
  final TrustRemoteDataSource _remoteDataSource;

  const TrustRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<TrustStats?>> getTrustStats(String photographerId) async {
    try {
      final dto = await _remoteDataSource.getTrustStats(photographerId);
      final stats = dto == null ? null : TrustStatsMapper.toDomain(dto);
      return Result.success(stats);
    } catch (_) {
      return Result.failure(const Failure(message: 'Failed to load trust stats'));
    }
  }

  @override
  Future<Result<void>> incrementReviewStats({
    required String bookingId,
    required String photographerId,
    required double qualityRating,
    required double communicationRating,
    required double onTimeRating,
    required double deliverySpeedRating,
  }) async {
    try {
      await _remoteDataSource.incrementReviewStats(
        bookingId: bookingId,
        photographerId: photographerId,
        qualityRating: qualityRating,
        communicationRating: communicationRating,
        onTimeRating: onTimeRating,
        deliverySpeedRating: deliverySpeedRating,
      );
      return Result.success(null);
    } catch (_) {
      return Result.failure(
        const Failure(message: 'Failed to update trust stats'),
      );
    }
  }

  @override
  Future<Result<void>> incrementCompletedBookings({
    required String bookingId,
    required String photographerId,
  }) async {
    try {
      await _remoteDataSource.incrementCompletedBookings(
        bookingId: bookingId,
        photographerId: photographerId,
      );
      return Result.success(null);
    } catch (_) {
      return Result.failure(
        const Failure(message: 'Failed to update trust stats'),
      );
    }
  }

  @override
  Future<Result<void>> incrementCanceledByPhotographer({
    required String bookingId,
    required String photographerId,
  }) async {
    try {
      await _remoteDataSource.incrementCanceledByPhotographer(
        bookingId: bookingId,
        photographerId: photographerId,
      );
      return Result.success(null);
    } catch (_) {
      return Result.failure(
        const Failure(message: 'Failed to update trust stats'),
      );
    }
  }

  @override
  Future<Result<void>> incrementDisputesCount({
    required String bookingId,
    required String photographerId,
  }) async {
    try {
      await _remoteDataSource.incrementDisputesCount(
        bookingId: bookingId,
        photographerId: photographerId,
      );
      return Result.success(null);
    } catch (_) {
      return Result.failure(
        const Failure(message: 'Failed to update trust stats'),
      );
    }
  }
}
