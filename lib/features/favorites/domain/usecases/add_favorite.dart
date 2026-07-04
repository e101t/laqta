import 'package:laqta/core/domain/result/result.dart';
import '../repositories/favorites_repository.dart';

class AddFavorite {
  final FavoritesRepository _repository;

  const AddFavorite(this._repository);

  Future<Result<void>> call({required String photographerId}) {
    return _repository.addFavorite(photographerId: photographerId);
  }
}
