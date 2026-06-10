import 'package:laqta/core/domain/failures/failure.dart';
import 'package:laqta/core/domain/result/result.dart';
import 'package:laqta/core/models/story_model.dart';
import 'package:laqta/features/story/data/datasources/story_remote_data_source.dart';
import 'package:laqta/features/story/domain/repositories/story_repository.dart';

class StoryRepositoryImpl implements StoryRepository {
  final StoryRemoteDataSource _remoteDataSource;

  const StoryRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<void>> createStory({required StoryModel story}) async {
    try {
      await _remoteDataSource.createStory(story);
      return Result.success(null);
    } catch (_) {
      return Result.failure(const Failure(message: 'Failed to create story'));
    }
  }

  @override
  Future<Result<String>> uploadStoryImage({
    required String photographerId,
    required String storyId,
    required String filePath,
    required String contentType,
  }) async {
    try {
      final url = await _remoteDataSource.uploadStoryImage(
        photographerId: photographerId,
        storyId: storyId,
        filePath: filePath,
        contentType: contentType,
      );
      return Result.success(url);
    } catch (_) {
      return Result.failure(const Failure(message: 'Failed to upload story'));
    }
  }
}
