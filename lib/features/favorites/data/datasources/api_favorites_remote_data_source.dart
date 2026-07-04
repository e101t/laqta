import 'package:laqta/core/services/backend_api_client.dart';
import 'package:laqta/features/favorites/data/datasources/favorites_remote_data_source.dart';
import 'package:laqta/features/favorites/data/dtos/favorite_dto.dart';
import 'package:laqta/features/photographer/data/dtos/photographer_dto.dart';
import 'package:laqta/features/profile/data/dtos/user_profile_dto.dart';

class ApiFavoritesRemoteDataSource implements FavoritesRemoteDataSource {
  ApiFavoritesRemoteDataSource({BackendApiClient? apiClient})
    : _apiClient = apiClient ?? BackendApiClient();

  final BackendApiClient _apiClient;

  @override
  Future<List<FavoriteDto>> getFavorites(String userId) async {
    final response = await _apiClient.get('/favorites/my');
    if (response is! Map<String, dynamic>) return const [];
    final list = response['favorites'];
    if (list is! List) return const [];
    return list
        .whereType<Map<Object?, Object?>>()
        .map((item) => FavoriteDto.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  @override
  Future<List<UserProfileDto>> getUserProfiles(List<String> userIds) async {
    if (userIds.isEmpty) return const [];
    final ids = userIds.map(Uri.encodeComponent).join(',');
    final response = await _apiClient.get('/users/public?ids=$ids');
    if (response is! Map<String, dynamic>) return const [];
    final list = response['users'];
    if (list is! List) return const [];
    return list
        .whereType<Map<Object?, Object?>>()
        .map((item) {
          final map = Map<String, dynamic>.from(item);
          final id = map['id'] as String? ?? map['uid'] as String? ?? '';
          return UserProfileDto.fromMap(id, map);
        })
        .toList();
  }

  @override
  Future<List<PhotographerDetailsDto>> getPhotographerDetails(
    List<String> photographerIds,
  ) async {
    if (photographerIds.isEmpty) return const [];
    final results = <PhotographerDetailsDto>[];
    for (final id in photographerIds) {
      try {
        final response = await _apiClient.get(
          '/explore/photographers/$id',
          authorized: false,
        );
        if (response is Map<String, dynamic>) {
          final profile = response['profile'];
          if (profile is Map<String, dynamic>) {
            results.add(PhotographerDetailsDto.fromJson({...profile, 'id': id}));
          }
        }
      } catch (_) {
        // skip photographers that fail to load
      }
    }
    return results;
  }

  @override
  Future<void> addFavorite(String photographerId) async {
    await _apiClient.post(
      '/favorites/${Uri.encodeComponent(photographerId)}',
      body: {},
    );
  }

  @override
  Future<bool> checkFavorite(String photographerId) async {
    try {
      final response = await _apiClient.get(
        '/favorites/check/${Uri.encodeComponent(photographerId)}',
      );
      if (response is Map<String, dynamic>) {
        return response['isFavorited'] == true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> removeFavorite(String userId, String photographerId) async {
    await _apiClient.delete(
      '/favorites/${Uri.encodeComponent(photographerId)}',
    );
  }
}
