import 'package:laqta/core/services/backend_api_client.dart';
import 'package:laqta/features/photographer/data/dtos/photographer_dto.dart';
import 'package:laqta/features/profile/data/dtos/user_profile_dto.dart';
import 'package:laqta/features/search/data/datasources/search_remote_data_source.dart';

class ApiSearchRemoteDataSource implements SearchRemoteDataSource {
  ApiSearchRemoteDataSource({BackendApiClient? apiClient})
    : _apiClient = apiClient ?? BackendApiClient();

  final BackendApiClient _apiClient;

  @override
  Future<List<UserProfileDto>> getPhotographerUsers() async {
    final photographers = await _fetchPhotographers();
    return photographers.map((item) {
      final id = item['id'] as String? ?? '';
      return UserProfileDto.fromMap(id, {...item, 'role': 'photographer'});
    }).toList();
  }

  @override
  Future<List<PhotographerDetailsDto>> getPhotographerDetails() async {
    final photographers = await _fetchPhotographers();
    return photographers
        .map((item) => PhotographerDetailsDto.fromJson(item))
        .toList();
  }

  Future<List<Map<String, dynamic>>> _fetchPhotographers() async {
    final response = await _apiClient.get(
      '/explore/marketplace',
      authorized: false,
    );
    if (response is! Map<String, dynamic>) return const [];
    final list = response['photographers'];
    if (list is! List) return const [];
    return list
        .whereType<Map<Object?, Object?>>()
        .map(Map<String, dynamic>.from)
        .toList();
  }
}
