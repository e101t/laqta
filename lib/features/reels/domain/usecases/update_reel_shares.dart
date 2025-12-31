import 'package:luqta/core/domain/result/result.dart';
import '../repositories/reels_repository.dart';

class UpdateReelShares {
  final ReelsRepository _repository;

  const UpdateReelShares(this._repository);

  Future<Result<void>> call({required String reelId, required int delta}) {
    return _repository.updateReelShares(reelId: reelId, delta: delta);
  }
}
