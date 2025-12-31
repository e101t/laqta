import 'package:luqta/core/domain/result/result.dart';
import '../entities/home_story.dart';
import '../repositories/home_repository.dart';

class GetActiveStories {
  final HomeRepository _repository;

  const GetActiveStories(this._repository);

  Future<Result<List<HomeStory>>> call({int limit = 50}) {
    return _repository.getActiveStories(limit: limit);
  }
}
