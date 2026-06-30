import 'package:laqta/core/services/backend_api_client.dart';
import 'package:laqta/features/loyalty/data/datasources/loyalty_remote_data_source.dart';
import 'package:laqta/features/loyalty/data/dtos/loyalty_points_dto.dart';

class ApiLoyaltyRemoteDataSource implements LoyaltyRemoteDataSource {
  ApiLoyaltyRemoteDataSource({BackendApiClient? apiClient})
    : _apiClient = apiClient ?? BackendApiClient();

  final BackendApiClient _apiClient;

  @override
  Future<LoyaltyPointsDto?> getLoyaltyPoints(String userId) async {
    try {
      final response = await _apiClient.get('/loyalty/my');
      if (response is! Map<String, dynamic>) return null;
      final data = response['loyalty'] is Map<String, dynamic>
          ? response['loyalty'] as Map<String, dynamic>
          : response;
      return LoyaltyPointsDto.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveLoyaltyPoints(
    String userId,
    LoyaltyPointsDto points,
  ) async {
    await _apiClient.patch('/loyalty/my', body: points.toJson());
  }
}
