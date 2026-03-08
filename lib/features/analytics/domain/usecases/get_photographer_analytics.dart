import 'package:luqta/core/domain/result/result.dart';
import 'package:luqta/features/analytics/domain/entities/analytics_metrics.dart';
import 'package:luqta/features/analytics/domain/repositories/analytics_repository.dart';

class GetPhotographerAnalytics {
  final AnalyticsRepository _repository;

  const GetPhotographerAnalytics(this._repository);

  Future<Result<AnalyticsMetrics>> call({
    required String photographerId,
    required String period,
  }) {
    return _repository.getPhotographerAnalytics(
      photographerId: photographerId,
      period: period,
    );
  }
}
