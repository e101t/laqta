import 'package:luqta/core/domain/result/result.dart';
import '../repositories/favorites_repository.dart';

class RemoveFavorite {
  final FavoritesRepository _repository;

  const RemoveFavorite(this._repository);

  Future<Result<void>> call({
    required String userId,
    required String photographerId,
  }) {
    return _repository.removeFavorite(
      userId: userId,
      photographerId: photographerId,
    );
  }
}
