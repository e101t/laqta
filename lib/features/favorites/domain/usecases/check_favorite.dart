import 'package:laqta/core/domain/result/result.dart';
import '../repositories/favorites_repository.dart';

class CheckFavorite {
  final FavoritesRepository _repository;

  const CheckFavorite(this._repository);

  Future<Result<bool>> call({required String photographerId}) {
    return _repository.checkFavorite(photographerId: photographerId);
  }
}
