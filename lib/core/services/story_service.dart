import 'package:laqta/core/models/story_model.dart';
import 'package:laqta/core/services/backend_api_client.dart';

class StoryService {
  StoryService({BackendApiClient? apiClient})
    : _apiClient = apiClient ?? BackendApiClient();

  final BackendApiClient _apiClient;

  Future<List<StoryModel>> fetchActiveStories({int limit = 50}) async {
    try {
      final response = await _apiClient.get('/stories?limit=$limit');
      final payload = response as Map<String, dynamic>;
      final storiesPayload =
          (payload['stories'] as List<dynamic>?)?.whereType<Map<String, dynamic>>() ??
          const Iterable<Map<String, dynamic>>.empty();
      return storiesPayload
          .map(StoryModel.fromJson)
          .where((story) => story.isActive)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> recordStoryView({
    required String storyId,
    required String userId,
  }) async {
    if (storyId.isEmpty || userId.isEmpty) return;
    try {
      await _apiClient.post('/stories/$storyId/views');
    } catch (_) {
      // Story views are best-effort.
    }
  }
}
