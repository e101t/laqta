import 'package:luqta/core/domain/result/result.dart';
import '../repositories/photographer_repository.dart';

class SetFavoriteStatus {
  final PhotographerRepository _repository;

  const SetFavoriteStatus(this._repository);

  Future<Result<void>> call({
    required String userId,
    required String photographerId,
    required bool isFavorite,
  }) {
    return _repository.setFavorite(
      userId: userId,
      photographerId: photographerId,
      isFavorite: isFavorite,
    );
  }
}
