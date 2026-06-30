import 'package:laqta/core/services/backend_api_client.dart';
import 'package:laqta/features/trust/data/datasources/trust_remote_data_source.dart';
import 'package:laqta/features/trust/data/dtos/trust_stats_dto.dart';

class ApiTrustRemoteDataSource implements TrustRemoteDataSource {
  ApiTrustRemoteDataSource({BackendApiClient? apiClient})
    : _apiClient = apiClient ?? BackendApiClient();

  final BackendApiClient _apiClient;

  @override
  Future<TrustStatsDto?> getTrustStats(String photographerId) async {
    try {
      final response = await _apiClient.get(
        '/trust/${Uri.encodeComponent(photographerId)}',
      );
      if (response is! Map<String, dynamic>) return null;
      final data = response['trust'] is Map<String, dynamic>
          ? response['trust'] as Map<String, dynamic>
          : response;
      return TrustStatsDto.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> incrementReviewStats({
    required String bookingId,
    required String photographerId,
    required double qualityRating,
    required double communicationRating,
    required double onTimeRating,
    required double deliverySpeedRating,
  }) async {
    await _apiClient.post('/trust/$photographerId/review', body: {
      'bookingId': bookingId,
      'qualityRating': qualityRating,
      'communicationRating': communicationRating,
      'onTimeRating': onTimeRating,
      'deliverySpeedRating': deliverySpeedRating,
    });
  }

  @override
  Future<void> incrementCompletedBookings({
    required String bookingId,
    required String photographerId,
  }) async {
    await _apiClient.post('/trust/$photographerId/completed', body: {
      'bookingId': bookingId,
    });
  }

  @override
  Future<void> incrementCanceledByPhotographer({
    required String bookingId,
    required String photographerId,
  }) async {
    await _apiClient.post('/trust/$photographerId/canceled', body: {
      'bookingId': bookingId,
    });
  }

  @override
  Future<void> incrementDisputesCount({
    required String bookingId,
    required String photographerId,
  }) async {
    await _apiClient.post('/trust/$photographerId/dispute', body: {
      'bookingId': bookingId,
    });
  }
}
