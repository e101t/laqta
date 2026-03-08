import 'package:luqta/core/domain/result/result.dart';
import '../repositories/story_repository.dart';

class UploadStoryImage {
  final StoryRepository _repository;

  const UploadStoryImage(this._repository);

  Future<Result<String>> call({
    required String photographerId,
    required String storyId,
    required String filePath,
    required String contentType,
  }) {
    return _repository.uploadStoryImage(
      photographerId: photographerId,
      storyId: storyId,
      filePath: filePath,
      contentType: contentType,
    );
  }
}
