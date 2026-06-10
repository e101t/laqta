import 'package:laqta/core/models/story_model.dart';

abstract class StoryRemoteDataSource {
  Future<String> uploadStoryImage({
    required String photographerId,
    required String storyId,
    required String filePath,
    required String contentType,
  });

  Future<void> createStory(StoryModel story);
}
