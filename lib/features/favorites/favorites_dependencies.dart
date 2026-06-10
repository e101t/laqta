import 'package:laqta/features/favorites/data/datasources/favorites_remote_data_source.dart';
import 'package:laqta/features/favorites/data/datasources/firestore_favorites_remote_data_source.dart';
import 'package:laqta/features/favorites/data/repositories/favorites_repository_impl.dart';
import 'package:laqta/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:laqta/features/favorites/domain/usecases/get_favorites.dart';
import 'package:laqta/features/favorites/domain/usecases/remove_favorite.dart';

class FavoritesDependencies {
  static final FavoritesRemoteDataSource _remoteDataSource =
      FirestoreFavoritesRemoteDataSource();
  static final FavoritesRepository _repository = FavoritesRepositoryImpl(
    _remoteDataSource,
  );

  static GetFavorites getFavorites() => GetFavorites(_repository);

  static RemoveFavorite removeFavorite() => RemoveFavorite(_repository);
}
