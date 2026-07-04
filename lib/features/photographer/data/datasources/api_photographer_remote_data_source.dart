import 'package:laqta/core/services/backend_api_client.dart';
import 'package:laqta/features/photographer/data/datasources/photographer_remote_data_source.dart';
import 'package:laqta/features/photographer/data/dtos/photographer_dto.dart';
import 'package:laqta/features/profile/data/dtos/portfolio_dto.dart';
import 'package:laqta/features/profile/data/dtos/user_profile_dto.dart';

class ApiPhotographerRemoteDataSource implements PhotographerRemoteDataSource {
  ApiPhotographerRemoteDataSource({BackendApiClient? apiClient})
    : _apiClient = apiClient ?? BackendApiClient();

  final BackendApiClient _apiClient;

  @override
  Future<UserProfileDto?> getUserProfile(String userId) async {
    try {
      final response = await _apiClient.get('/users/public?ids=$userId');
      if (response is! Map<String, dynamic>) return null;
      final list = response['users'];
      if (list is! List || list.isEmpty) return null;
      final item = list.first;
      if (item is! Map) return null;
      final map = Map<String, dynamic>.from(item);
      return UserProfileDto.fromMap(userId, map);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<PhotographerDetailsDto?> getPhotographerDetails(
    String photographerId,
  ) async {
    try {
      final response = await _apiClient.get(
        '/explore/photographers/$photographerId',
        authorized: false,
      );
      if (response is! Map<String, dynamic>) return null;
      final profile = response['profile'];
      if (profile is! Map<String, dynamic>) return null;
      return PhotographerDetailsDto.fromJson({
        ...profile,
        'id': photographerId,
      });
    } catch (_) {
      return null;
    }
  }

  @override
  Future<PortfolioDto?> getPortfolio(String photographerId) async {
    try {
      final response = await _apiClient.get(
        '/explore/photographers/$photographerId',
        authorized: false,
      );
      if (response is! Map<String, dynamic>) return null;
      final profile = response['profile'];
      if (profile is! Map<String, dynamic>) return null;
      final portfolio = profile['portfolio'];
      final images = portfolio is List
          ? portfolio
                .whereType<Map<dynamic, dynamic>>()
                .map(
                  (item) => PortfolioImageDto.fromMap(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .toList()
          : <PortfolioImageDto>[];
      return PortfolioDto(
        id: photographerId,
        photographerId: photographerId,
        images: images,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<PhotographerReviewDto>> getReviews(
    String photographerId, {
    int limit = 10,
  }) async {
    try {
      final response = await _apiClient.get(
        '/reviews?targetId=${Uri.encodeComponent(photographerId)}&limit=$limit',
      );
      if (response is! Map<String, dynamic>) return const [];
      final list = response['reviews'];
      if (list is! List) return const [];
      return list
          .whereType<Map<Object?, Object?>>()
          .map(
            (item) =>
                PhotographerReviewDto.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<bool> isFavorite(String userId, String photographerId) async {
    try {
      final response = await _apiClient.get(
        '/favorites/check/${Uri.encodeComponent(photographerId)}',
      );
      if (response is! Map<String, dynamic>) return false;
      return response['isFavorited'] == true || response['isFavorite'] == true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> setFavorite(
    String userId,
    String photographerId,
    bool isFavorite,
  ) async {
    if (isFavorite) {
      await _apiClient.post(
        '/favorites/${Uri.encodeComponent(photographerId)}',
        body: {},
      );
    } else {
      await _apiClient.delete(
        '/favorites/${Uri.encodeComponent(photographerId)}',
      );
    }
  }
}
