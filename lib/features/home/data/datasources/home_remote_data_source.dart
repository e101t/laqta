import 'package:luqta/core/models/photographer_profile.dart';
import 'package:luqta/core/models/story_model.dart';

abstract class HomeRemoteDataSource {
  Future<List<StoryModel>> fetchActiveStories({int limit = 50});

  Future<void> recordStoryView({
    required String storyId,
    required String userId,
  });

  Future<List<PhotographerProfile>> fetchPhotographers({
    String? governorate,
    String? specialty,
    String? gender,
    double minRating = 0,
    int limit = 50,
  });

  Future<Set<String>> fetchFollowingIds(String userId);

  Future<void> setFollowStatus({
    required String followerId,
    required String targetId,
    required bool follow,
  });
}
