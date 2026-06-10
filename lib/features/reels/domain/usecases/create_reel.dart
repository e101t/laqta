import 'package:laqta/core/domain/result/result.dart';
import '../entities/reel_model.dart';
import '../repositories/reels_repository.dart';

class CreateReel {
  final ReelsRepository _repository;

  const CreateReel(this._repository);

  Future<Result<void>> call({required ReelModel reel}) {
    return _repository.createReel(reel: reel);
  }
}
