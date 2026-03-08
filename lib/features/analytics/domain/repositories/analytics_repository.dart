import 'package:luqta/core/domain/result/result.dart';
import 'package:luqta/features/analytics/domain/entities/analytics_metrics.dart';

abstract class AnalyticsRepository {
  Future<Result<AnalyticsMetrics>> getPhotographerAnalytics({
    required String photographerId,
    required String period,
  });
}
