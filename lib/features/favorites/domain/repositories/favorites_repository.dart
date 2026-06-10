import 'package:laqta/core/domain/result/result.dart';
import '../entities/favorite_photographer.dart';

abstract class FavoritesRepository {
  Future<Result<List<FavoritePhotographer>>> getFavorites({
    required String userId,
  });

  Future<Result<void>> removeFavorite({
    required String userId,
    required String photographerId,
  });
}
