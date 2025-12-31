import 'package:luqta/features/favorites/data/dtos/favorite_dto.dart';
import 'package:luqta/features/photographer/data/dtos/photographer_dto.dart';
import 'package:luqta/features/profile/data/dtos/user_profile_dto.dart';

abstract class FavoritesRemoteDataSource {
  Future<List<FavoriteDto>> getFavorites(String userId);

  Future<List<UserProfileDto>> getUserProfiles(List<String> userIds);

  Future<List<PhotographerDetailsDto>> getPhotographerDetails(
    List<String> photographerIds,
  );

  Future<void> removeFavorite(String userId, String photographerId);
}
