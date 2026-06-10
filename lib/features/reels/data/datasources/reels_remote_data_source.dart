import 'package:laqta/features/reels/data/dtos/comment_dto.dart';
import 'package:laqta/features/reels/data/dtos/reel_dto.dart';

abstract class ReelsRemoteDataSource {
  Future<List<ReelDto>> getReels();

  Future<void> createReel(ReelDto reel);

  Future<void> updateReelCounter({
    required String reelId,
    required String field,
    required int delta,
  });

  Future<String> uploadReelMedia({
    required String photographerId,
    required String reelId,
    required String filePath,
    required String contentType,
  });

  Future<List<CommentDto>> getComments(String reelId);

  Future<void> addComment(CommentDto comment);
}
