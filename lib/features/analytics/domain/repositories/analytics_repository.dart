import 'package:laqta/core/domain/result/result.dart';
import 'package:laqta/features/analytics/domain/entities/analytics_metrics.dart';

abstract class AnalyticsRepository {
  Future<Result<AnalyticsMetrics>> getPhotographerAnalytics({
    required String photographerId,
    required String period,
  });
}
