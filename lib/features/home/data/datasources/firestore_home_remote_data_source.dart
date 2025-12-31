import 'package:luqta/core/models/photographer_profile.dart';
import 'package:luqta/core/models/story_model.dart';
import 'package:luqta/core/services/follow_service.dart';
import 'package:luqta/core/services/photographer_service.dart';
import 'package:luqta/core/services/story_service.dart';
import 'home_remote_data_source.dart';

class FirestoreHomeRemoteDataSource implements HomeRemoteDataSource {
  final StoryService _storyService;
  final PhotographerService _photographerService;
  final FollowService _followService;

  FirestoreHomeRemoteDataSource({
    StoryService? storyService,
    PhotographerService? photographerService,
    FollowService? followService,
  }) : _storyService = storyService ?? StoryService(),
       _photographerService = photographerService ?? PhotographerService(),
       _followService = followService ?? FollowService();

  @override
  Future<List<StoryModel>> fetchActiveStories({int limit = 50}) {
    return _storyService.fetchActiveStories(limit: limit);
  }

  @override
  Future<void> recordStoryView({
    required String storyId,
    required String userId,
  }) {
    return _storyService.recordStoryView(storyId: storyId, userId: userId);
  }

  @override
  Future<List<PhotographerProfile>> fetchPhotographers({
    String? governorate,
    String? specialty,
    String? gender,
    double minRating = 0,
    int limit = 50,
  }) {
    return _photographerService.fetchPhotographers(
      governorate: governorate,
      specialty: specialty,
      gender: gender,
      minRating: minRating,
      limit: limit,
    );
  }

  @override
  Future<Set<String>> fetchFollowingIds(String userId) {
    return _followService.fetchFollowing(userId);
  }

  @override
  Future<void> setFollowStatus({
    required String followerId,
    required String targetId,
    required bool follow,
  }) {
    return _followService.setFollowStatus(
      followerId: followerId,
      targetId: targetId,
      follow: follow,
    );
  }
}
