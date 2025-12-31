import 'package:luqta/core/domain/result/result.dart';
import '../repositories/reels_repository.dart';

class UpdateReelLikes {
  final ReelsRepository _repository;

  const UpdateReelLikes(this._repository);

  Future<Result<void>> call({required String reelId, required int delta}) {
    return _repository.updateReelLikes(reelId: reelId, delta: delta);
  }
}
