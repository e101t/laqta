import 'package:laqta/core/services/backend_api_client.dart';
import 'package:laqta/core/services/backend_media_service.dart';
import 'package:laqta/core/services/backend_session_service.dart';
import 'package:laqta/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:laqta/features/profile/data/dtos/portfolio_dto.dart';
import 'package:laqta/features/profile/data/dtos/user_profile_dto.dart';

class ApiProfileRemoteDataSource implements ProfileRemoteDataSource {
  ApiProfileRemoteDataSource({
    BackendApiClient? apiClient,
    BackendMediaService? mediaService,
    BackendSessionService? sessionService,
  }) : _apiClient = apiClient ?? BackendApiClient(),
       _mediaService = mediaService ?? BackendMediaService(),
       _sessionService = sessionService ?? BackendSessionService();

  final BackendApiClient _apiClient;
  final BackendMediaService _mediaService;
  final BackendSessionService _sessionService;

  @override
  Future<UserProfileDto?> getUserProfile(String userId) async {
    final currentUserId = await _sessionService.getUserId();
    final Object? response;
    if (currentUserId == userId) {
      response = await _apiClient.get('/users/me');
      final payload = _asMap(response);
      return UserProfileDto.fromMap(userId, _asMap(payload['user']));
    }

    response = await _apiClient.get('/users/public?ids=$userId');
    final payload = _asMap(response);
    final users = payload['users'];
    if (users is List && users.isNotEmpty) {
      return UserProfileDto.fromMap(userId, _asMap(users.first));
    }
    return null;
  }

  @override
  Future<void> updateUserProfile(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    await _apiClient.patch('/users/me', body: _sanitizeUserPayload(updates));
  }

  @override
  Future<void> saveBasicInfo(String userId, Map<String, dynamic> data) async {
    await updateUserProfile(userId, data);
  }

  @override
  Future<bool> isUsernameAvailable(String usernameLower) async {
    final response = await _apiClient.get(
      '/users/username/$usernameLower/availability',
    );
    final payload = _asMap(response);
    return payload['available'] == true;
  }

  @override
  Future<String> uploadProfilePhoto(String userId, String filePath) {
    return _mediaService.uploadFile(
      entityType: 'user',
      entityId: userId,
      filePath: filePath,
      publicContent: true,
    );
  }

  @override
  Future<PortfolioDto?> getPortfolio(String photographerId) async {
    final response = await _apiClient.get(
      '/explore/photographers/${Uri.encodeComponent(photographerId)}',
    );
    final payload = _asMap(response);
    final profile = _asMap(payload['profile']);
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
  }

  @override
  Future<void> savePortfolio(
    String photographerId,
    List<PortfolioImageDto> images,
  ) async {
    // Portfolio ordering is persisted by the backend media references created
    // during upload; this endpoint is intentionally a no-op until portfolio
    // ordering is exposed by the API.
  }

  @override
  Future<String> uploadPortfolioImage(String photographerId, String filePath) {
    return _mediaService.uploadFile(
      entityType: 'portfolio',
      entityId: photographerId,
      filePath: filePath,
      publicContent: true,
    );
  }

  @override
  Future<void> deleteFileByUrl(String url) async {
    await _mediaService.deleteByUrl(url);
  }

  Map<String, dynamic> _sanitizeUserPayload(Map<String, dynamic> updates) {
    final payload = Map<String, dynamic>.from(updates)
      ..remove('age')
      ..remove('usernameLower')
      ..removeWhere((_, value) => value == null);
    return payload;
  }

  Map<String, dynamic> _asMap(Object? value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return <String, dynamic>{};
  }
}
