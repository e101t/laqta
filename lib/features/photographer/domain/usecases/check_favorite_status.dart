import 'package:luqta/core/domain/result/result.dart';
import '../repositories/photographer_repository.dart';

class CheckFavoriteStatus {
  final PhotographerRepository _repository;

  const CheckFavoriteStatus(this._repository);

  Future<Result<bool>> call({
    required String userId,
    required String photographerId,
  }) {
    return _repository.isFavorite(
      userId: userId,
      photographerId: photographerId,
    );
  }
}
