import 'package:luqta/core/domain/result/result.dart';
import '../entities/comment_model.dart';
import '../repositories/reels_repository.dart';

class GetReelComments {
  final ReelsRepository _repository;

  const GetReelComments(this._repository);

  Future<Result<List<CommentModel>>> call({required String reelId}) {
    return _repository.getComments(reelId: reelId);
  }
}
