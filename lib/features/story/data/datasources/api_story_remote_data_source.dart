import 'package:laqta/core/models/story_model.dart';
import 'package:laqta/core/services/backend_api_client.dart';
import 'package:laqta/core/services/backend_media_service.dart';
import 'package:laqta/features/story/data/datasources/story_remote_data_source.dart';

class ApiStoryRemoteDataSource implements StoryRemoteDataSource {
  ApiStoryRemoteDataSource({
    BackendApiClient? apiClient,
    BackendMediaService? backendMediaService,
  }) : _apiClient = apiClient ?? BackendApiClient(),
       _backendMediaService = backendMediaService ?? BackendMediaService();

  final BackendApiClient _apiClient;
  final BackendMediaService _backendMediaService;

  @override
  Future<void> createStory(StoryModel story) async {
    await _apiClient.post('/stories', body: story.toBackendJson());
  }

  @override
  Future<String> uploadStoryImage({
    required String photographerId,
    required String storyId,
    required String filePath,
    required String contentType,
  }) {
    return _backendMediaService.uploadFile(
      entityType: 'story',
      entityId: photographerId,
      filePath: filePath,
      publicContent: true,
    );
  }
}
