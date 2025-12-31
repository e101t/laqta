import 'package:luqta/core/domain/result/result.dart';
import '../entities/home_photographer.dart';
import '../entities/home_story.dart';

abstract class HomeRepository {
  Future<Result<List<HomeStory>>> getActiveStories({int limit = 50});

  Future<Result<void>> recordStoryView({
    required String storyId,
    required String userId,
  });

  Future<Result<List<HomePhotographer>>> getPhotographers({
    String? governorate,
    String? specialty,
    String? gender,
    double minRating = 0,
    int limit = 50,
  });

  Future<Result<Set<String>>> getFollowingIds({required String userId});

  Future<Result<void>> setFollowStatus({
    required String followerId,
    required String targetId,
    required bool follow,
  });
}
