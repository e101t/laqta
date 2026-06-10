import 'package:laqta/features/analytics/domain/entities/analytics_metrics.dart';

abstract class AnalyticsRemoteDataSource {
  Future<AnalyticsMetrics> getPhotographerAnalytics({
    required String photographerId,
    required String period,
  });
}
