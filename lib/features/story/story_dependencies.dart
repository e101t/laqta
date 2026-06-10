import 'package:flutter/foundation.dart';
import 'package:laqta/features/story/data/datasources/api_story_remote_data_source.dart';
import 'package:laqta/features/story/data/datasources/story_remote_data_source.dart';
import 'package:laqta/features/story/data/repositories/story_repository_impl.dart';
import 'package:laqta/features/story/domain/repositories/story_repository.dart';
import 'package:laqta/features/story/domain/usecases/create_story.dart';
import 'package:laqta/features/story/domain/usecases/upload_story_image.dart';

class StoryDependencies {
  static final StoryRemoteDataSource _remoteDataSource =
      ApiStoryRemoteDataSource();
  static StoryRepository? _repositoryOverride;

  @visibleForTesting
  static void setRepositoryOverride(StoryRepository? repository) {
    _repositoryOverride = repository;
  }

  static StoryRepository get _repository =>
      _repositoryOverride ?? StoryRepositoryImpl(_remoteDataSource);

  static UploadStoryImage uploadStoryImage() => UploadStoryImage(_repository);

  static CreateStory createStory() => CreateStory(_repository);
}
