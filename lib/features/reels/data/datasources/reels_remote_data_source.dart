import 'package:luqta/features/reels/data/dtos/comment_dto.dart';
import 'package:luqta/features/reels/data/dtos/reel_dto.dart';

abstract class ReelsRemoteDataSource {
  Future<List<ReelDto>> getReels();

  Future<void> updateReelCounter({
    required String reelId,
    required String field,
    required int delta,
  });

  Future<List<CommentDto>> getComments(String reelId);

  Future<void> addComment(CommentDto comment);
}
