import 'package:luqta/core/domain/failures/failure.dart';
import 'package:luqta/core/domain/result/result.dart';
import 'package:luqta/features/home/data/mappers/home_photographer_mapper.dart';
import 'package:luqta/features/home/data/mappers/home_story_mapper.dart';
import 'package:luqta/features/home/domain/entities/home_photographer.dart';
import 'package:luqta/features/home/domain/entities/home_story.dart';
import 'package:luqta/features/home/domain/repositories/home_repository.dart';
import '../datasources/home_remote_data_source.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource _remoteDataSource;

  const HomeRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<List<HomeStory>>> getActiveStories({int limit = 50}) async {
    try {
      final stories = await _remoteDataSource.fetchActiveStories(limit: limit);
      final mapped = stories.map(HomeStoryMapper.fromModel).toList();
      return Result.success(mapped);
    } catch (e) {
      return Result.failure(const Failure(message: 'Failed to load stories'));
    }
  }

  @override
  Future<Result<void>> recordStoryView({
    required String storyId,
    required String userId,
  }) async {
    try {
      await _remoteDataSource.recordStoryView(storyId: storyId, userId: userId);
      return Result.success(null);
    } catch (e) {
      return Result.failure(
        const Failure(message: 'Failed to record story view'),
      );
    }
  }

  @override
  Future<Result<List<HomePhotographer>>> getPhotographers({
    String? governorate,
    String? specialty,
    String? gender,
    double minRating = 0,
    int limit = 50,
  }) async {
    try {
      final profiles = await _remoteDataSource.fetchPhotographers(
        governorate: governorate,
        specialty: specialty,
        gender: gender,
        minRating: minRating,
        limit: limit,
      );
      final mapped = profiles.map(HomePhotographerMapper.fromProfile).toList();
      return Result.success(mapped);
    } catch (e) {
      return Result.failure(
        const Failure(message: 'Failed to load photographers'),
      );
    }
  }

  @override
  Future<Result<Set<String>>> getFollowingIds({required String userId}) async {
    try {
      final ids = await _remoteDataSource.fetchFollowingIds(userId);
      return Result.success(ids);
    } catch (e) {
      return Result.failure(const Failure(message: 'Failed to load following'));
    }
  }

  @override
  Future<Result<void>> setFollowStatus({
    required String followerId,
    required String targetId,
    required bool follow,
  }) async {
    try {
      await _remoteDataSource.setFollowStatus(
        followerId: followerId,
        targetId: targetId,
        follow: follow,
      );
      return Result.success(null);
    } catch (e) {
      return Result.failure(
        const Failure(message: 'Failed to update follow status'),
      );
    }
  }
}
