import 'package:laqta/core/services/backend_api_client.dart';
import 'package:laqta/features/achievements/data/datasources/achievements_remote_data_source.dart';
import 'package:laqta/features/achievements/data/dtos/user_achievement_dto.dart';

class ApiAchievementsRemoteDataSource implements AchievementsRemoteDataSource {
  ApiAchievementsRemoteDataSource({BackendApiClient? apiClient})
    : _apiClient = apiClient ?? BackendApiClient();

  final BackendApiClient _apiClient;

  @override
  Future<List<UserAchievementDto>> getUserAchievements(String userId) async {
    final response = await _apiClient.get('/achievements/my');
    if (response is! Map<String, dynamic>) return const [];
    final list = response['achievements'];
    if (list is! List) return const [];
    return list
        .whereType<Map<Object?, Object?>>()
        .map(
          (item) =>
              UserAchievementDto.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }
}
