import 'package:luqta/features/photographer/data/dtos/photographer_dto.dart';
import 'package:luqta/features/profile/data/dtos/portfolio_dto.dart';
import 'package:luqta/features/profile/data/dtos/user_profile_dto.dart';

abstract class PhotographerRemoteDataSource {
  Future<UserProfileDto?> getUserProfile(String userId);

  Future<PhotographerDetailsDto?> getPhotographerDetails(String photographerId);

  Future<PortfolioDto?> getPortfolio(String photographerId);

  Future<List<PhotographerReviewDto>> getReviews(
    String photographerId, {
    int limit = 10,
  });

  Future<bool> isFavorite(String userId, String photographerId);

  Future<void> setFavorite(
    String userId,
    String photographerId,
    bool isFavorite,
  );
}
