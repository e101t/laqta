import 'package:luqta/core/domain/failures/failure.dart';
import 'package:luqta/core/domain/result/result.dart';
import 'package:luqta/features/reels/data/datasources/reels_remote_data_source.dart';
import 'package:luqta/features/reels/data/mappers/reels_mapper.dart';
import 'package:luqta/features/reels/domain/entities/comment_model.dart';
import 'package:luqta/features/reels/domain/entities/reel_model.dart';
import 'package:luqta/features/reels/domain/repositories/reels_repository.dart';

class ReelsRepositoryImpl implements ReelsRepository {
  final ReelsRemoteDataSource _remoteDataSource;

  const ReelsRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<List<ReelModel>>> getReels() async {
    try {
      final dtos = await _remoteDataSource.getReels();
      final reels = dtos.map(ReelsMapper.toReel).toList();
      return Result.success(reels);
    } catch (_) {
      return Result.failure(const Failure(message: 'Failed to load reels'));
    }
  }

  @override
  Future<Result<void>> createReel({required ReelModel reel}) async {
    try {
      await _remoteDataSource.createReel(ReelsMapper.toReelDto(reel));
      return Result.success(null);
    } catch (_) {
      return Result.failure(const Failure(message: 'Failed to create post'));
    }
  }

  @override
  Future<Result<String>> uploadReelMedia({
    required String photographerId,
    required String reelId,
    required String filePath,
    required String contentType,
  }) async {
    try {
      final url = await _remoteDataSource.uploadReelMedia(
        photographerId: photographerId,
        reelId: reelId,
        filePath: filePath,
        contentType: contentType,
      );
      return Result.success(url);
    } catch (_) {
      return Result.failure(
        const Failure(message: 'Failed to upload media'),
      );
    }
  }

  @override
  Future<Result<void>> updateReelLikes({
    required String reelId,
    required int delta,
  }) async {
    try {
      await _remoteDataSource.updateReelCounter(
        reelId: reelId,
        field: 'likes',
        delta: delta,
      );
      return Result.success(null);
    } catch (_) {
      return Result.failure(const Failure(message: 'Failed to update likes'));
    }
  }

  @override
  Future<Result<void>> updateReelShares({
    required String reelId,
    required int delta,
  }) async {
    try {
      await _remoteDataSource.updateReelCounter(
        reelId: reelId,
        field: 'shares',
        delta: delta,
      );
      return Result.success(null);
    } catch (_) {
      return Result.failure(const Failure(message: 'Failed to update shares'));
    }
  }

  @override
  Future<Result<List<CommentModel>>> getComments({
    required String reelId,
  }) async {
    try {
      final dtos = await _remoteDataSource.getComments(reelId);
      final comments = dtos.map(ReelsMapper.toComment).toList();
      return Result.success(comments);
    } catch (_) {
      return Result.failure(const Failure(message: 'Failed to load comments'));
    }
  }

  @override
  Future<Result<void>> addComment({required CommentModel comment}) async {
    try {
      await _remoteDataSource.addComment(ReelsMapper.toCommentDto(comment));
      await _remoteDataSource.updateReelCounter(
        reelId: comment.reelId,
        field: 'comments',
        delta: 1,
      );
      return Result.success(null);
    } catch (_) {
      return Result.failure(const Failure(message: 'Failed to add comment'));
    }
  }
}
