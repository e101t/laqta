import 'package:laqta/core/domain/result/result.dart';
import '../entities/reel_model.dart';
import '../repositories/reels_repository.dart';

class GetReels {
  final ReelsRepository _repository;

  const GetReels(this._repository);

  Future<Result<List<ReelModel>>> call() {
    return _repository.getReels();
  }
}
