import 'package:luqta/core/domain/result/result.dart';
import '../entities/favorite_photographer.dart';
import '../repositories/favorites_repository.dart';

class GetFavorites {
  final FavoritesRepository _repository;

  const GetFavorites(this._repository);

  Future<Result<List<FavoritePhotographer>>> call({required String userId}) {
    return _repository.getFavorites(userId: userId);
  }
}
