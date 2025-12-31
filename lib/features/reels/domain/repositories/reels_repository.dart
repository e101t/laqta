import 'package:luqta/core/domain/result/result.dart';
import '../entities/comment_model.dart';
import '../entities/reel_model.dart';

abstract class ReelsRepository {
  Future<Result<List<ReelModel>>> getReels();

  Future<Result<void>> updateReelLikes({
    required String reelId,
    required int delta,
  });

  Future<Result<void>> updateReelShares({
    required String reelId,
    required int delta,
  });

  Future<Result<List<CommentModel>>> getComments({required String reelId});

  Future<Result<void>> addComment({required CommentModel comment});
}
