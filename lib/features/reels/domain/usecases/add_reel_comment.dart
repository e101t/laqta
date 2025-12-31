import 'package:luqta/core/domain/result/result.dart';
import '../entities/comment_model.dart';
import '../repositories/reels_repository.dart';

class AddReelComment {
  final ReelsRepository _repository;

  const AddReelComment(this._repository);

  Future<Result<void>> call({required CommentModel comment}) {
    return _repository.addComment(comment: comment);
  }
}
