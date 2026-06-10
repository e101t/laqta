import 'package:laqta/core/domain/failures/failure.dart';
import 'package:laqta/core/domain/result/result.dart';
import 'package:laqta/features/favorites/data/datasources/favorites_remote_data_source.dart';
import 'package:laqta/features/favorites/domain/entities/favorite_photographer.dart';
import 'package:laqta/features/favorites/domain/repositories/favorites_repository.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoritesRemoteDataSource _remoteDataSource;

  const FavoritesRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<List<FavoritePhotographer>>> getFavorites({
    required String userId,
  }) async {
    try {
      final favorites = await _remoteDataSource.getFavorites(userId);
      final photographerIds = favorites
          .map((favorite) => favorite.photographerId)
          .where((id) => id.isNotEmpty)
          .toList();

      if (photographerIds.isEmpty) {
        return Result.success(<FavoritePhotographer>[]);
      }

      final users = await _remoteDataSource.getUserProfiles(photographerIds);
      final photographers = await _remoteDataSource.getPhotographerDetails(
        photographerIds,
      );

      final userMap = {for (final user in users) user.id: user};
      final photographerMap = {
        for (final photographer in photographers) photographer.id: photographer,
      };

      final results = <FavoritePhotographer>[];
      for (final photographerId in photographerIds) {
        final user = userMap[photographerId];
        final photographer = photographerMap[photographerId];
        if (user == null || photographer == null) {
          continue;
        }

        results.add(
          FavoritePhotographer(
            id: photographerId,
            name: user.name,
            image: user.photoUrl ?? '',
            specialties: photographer.specialties,
            rating: photographer.rate,
            reviewCount: photographer.reviewsCount,
            startingPrice: photographer.basePrice,
            governorate: user.governorate,
            username: user.username,
            gender: user.gender,
            age: user.age,
          ),
        );
      }

      return Result.success(results);
    } catch (_) {
      return Result.failure(const Failure(message: 'Failed to load favorites'));
    }
  }

  @override
  Future<Result<void>> removeFavorite({
    required String userId,
    required String photographerId,
  }) async {
    try {
      await _remoteDataSource.removeFavorite(userId, photographerId);
      return Result.success(null);
    } catch (_) {
      return Result.failure(
        const Failure(message: 'Failed to remove from favorites'),
      );
    }
  }
}
