import 'package:laqta/core/domain/failures/failure.dart';
import 'package:laqta/core/domain/result/result.dart';
import 'package:laqta/features/analytics/data/datasources/analytics_remote_data_source.dart';
import 'package:laqta/features/analytics/domain/entities/analytics_metrics.dart';
import 'package:laqta/features/analytics/domain/repositories/analytics_repository.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final AnalyticsRemoteDataSource _remoteDataSource;

  AnalyticsRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<AnalyticsMetrics>> getPhotographerAnalytics({
    required String photographerId,
    required String period,
  }) async {
    try {
      final metrics = await _remoteDataSource.getPhotographerAnalytics(
        photographerId: photographerId,
        period: period,
      );
      return Result.success(metrics);
    } catch (_) {
      return Result.failure(const Failure(message: 'Failed to load analytics'));
    }
  }
}
