import 'package:luqta/core/domain/result/result.dart';
import 'package:luqta/core/models/story_model.dart';
import '../repositories/story_repository.dart';

class CreateStory {
  final StoryRepository _repository;

  const CreateStory(this._repository);

  Future<Result<void>> call({required StoryModel story}) {
    return _repository.createStory(story: story);
  }
}
