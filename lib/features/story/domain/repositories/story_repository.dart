import 'package:luqta/core/domain/result/result.dart';
import 'package:luqta/core/models/story_model.dart';

abstract class StoryRepository {
  Future<Result<void>> createStory({required StoryModel story});

  Future<Result<String>> uploadStoryImage({
    required String photographerId,
    required String storyId,
    required String filePath,
    required String contentType,
  });
}
