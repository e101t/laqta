import 'package:laqta/core/services/backend_api_client.dart';
import 'package:laqta/features/analytics/data/datasources/analytics_remote_data_source.dart';
import 'package:laqta/features/analytics/domain/entities/analytics_metrics.dart';

class ApiAnalyticsRemoteDataSource implements AnalyticsRemoteDataSource {
  ApiAnalyticsRemoteDataSource({BackendApiClient? apiClient})
    : _apiClient = apiClient ?? BackendApiClient();

  final BackendApiClient _apiClient;

  @override
  Future<AnalyticsMetrics> getPhotographerAnalytics({
    required String photographerId,
    required String period,
  }) async {
    final response = await _apiClient.get(
      '/analytics/photographer/${Uri.encodeComponent(photographerId)}?period=${Uri.encodeComponent(period)}',
    );
    final data = response is Map<String, dynamic> ? response : <String, dynamic>{};
    final metrics = data['metrics'] is Map<String, dynamic>
        ? data['metrics'] as Map<String, dynamic>
        : data;
    return AnalyticsMetrics(
      totalViews: _readInt(metrics, 'totalViews'),
      profileClicks: _readInt(metrics, 'profileClicks'),
      bookingRequests: _readInt(metrics, 'bookingRequests'),
      completedBookings: _readInt(metrics, 'completedBookings'),
      revenue: _readDouble(metrics, 'revenue'),
      newFollowers: _readInt(metrics, 'newFollowers'),
      storyViews: _readInt(metrics, 'storyViews'),
      avgRating: _readDouble(metrics, 'avgRating'),
    );
  }

  static int _readInt(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    return 0;
  }

  static double _readDouble(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return 0;
  }
}
