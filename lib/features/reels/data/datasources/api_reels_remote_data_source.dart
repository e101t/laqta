import 'package:laqta/core/constants/app_constants.dart';
import 'package:laqta/core/services/backend_api_client.dart';
import 'package:laqta/core/services/backend_media_service.dart';
import 'package:laqta/features/reels/data/datasources/reels_remote_data_source.dart';
import 'package:laqta/features/reels/data/dtos/comment_dto.dart';
import 'package:laqta/features/reels/data/dtos/reel_dto.dart';

class ApiReelsRemoteDataSource implements ReelsRemoteDataSource {
  ApiReelsRemoteDataSource({
    BackendApiClient? apiClient,
    BackendMediaService? backendMediaService,
  }) : _apiClient = apiClient ?? BackendApiClient(),
       _backendMedia = backendMediaService ?? BackendMediaService();

  final BackendApiClient _apiClient;
  final BackendMediaService _backendMedia;

  @override
  Future<List<ReelDto>> getReels() async {
    final response = await _apiClient.get(
      '/reels?limit=${AppConstants.queryLimit}',
    );
    final payload = response as Map<String, dynamic>;
    final reels =
        (payload['reels'] as List<dynamic>?)
            ?.whereType<Map<String, dynamic>>()
            .map(ReelDto.fromJson)
            .toList() ??
        const <ReelDto>[];
    return reels;
  }

  @override
  Future<void> createReel(ReelDto reel) async {
    await _apiClient.post('/reels', body: reel.toBackendJson());
  }

  @override
  Future<void> updateReelCounter({
    required String reelId,
    required String field,
    required int delta,
  }) async {
    await _apiClient.post(
      '/reels/$reelId/counters',
      body: {'field': field, 'delta': delta},
    );
  }

  @override
  Future<String> uploadReelMedia({
    required String photographerId,
    required String reelId,
    required String filePath,
    required String contentType,
  }) {
    return _backendMedia.uploadFile(
      entityType: 'reel',
      entityId: photographerId,
      filePath: filePath,
      publicContent: true,
    );
  }

  @override
  Future<List<CommentDto>> getComments(String reelId) async {
    final response = await _apiClient.get('/reels/$reelId/comments');
    final payload = response as Map<String, dynamic>;
    final comments =
        (payload['comments'] as List<dynamic>?)
            ?.whereType<Map<String, dynamic>>()
            .map(CommentDto.fromJson)
            .toList() ??
        const <CommentDto>[];
    return comments;
  }

  @override
  Future<void> addComment(CommentDto comment) async {
    await _apiClient.post(
      '/reels/${comment.reelId}/comments',
      body: comment.toBackendJson(),
    );
  }
}
