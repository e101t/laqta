import 'package:luqta/core/domain/failures/failure.dart';
import 'package:luqta/core/domain/result/result.dart';
import 'package:luqta/features/photographer/data/datasources/photographer_remote_data_source.dart';
import 'package:luqta/features/photographer/data/mappers/photographer_mapper.dart';
import 'package:luqta/features/photographer/domain/entities/photographer_profile_bundle.dart';
import 'package:luqta/features/photographer/domain/repositories/photographer_repository.dart';

class PhotographerRepositoryImpl implements PhotographerRepository {
  final PhotographerRemoteDataSource _remoteDataSource;

  const PhotographerRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<PhotographerProfileBundle>> getPhotographerProfile({
    required String photographerId,
  }) async {
    try {
      final userDto = await _remoteDataSource.getUserProfile(photographerId);
      if (userDto == null) {
        return Result.failure(const Failure(message: 'Photographer not found'));
      }

      final photographerDto = await _remoteDataSource.getPhotographerDetails(
        photographerId,
      );
      if (photographerDto == null) {
        return Result.failure(
          const Failure(message: 'Photographer profile not found'),
        );
      }

      final portfolioDto = await _remoteDataSource.getPortfolio(photographerId);
      final reviewDtos = await _remoteDataSource.getReviews(photographerId);

      final user = PhotographerMapper.toDomainUser(userDto);
      final photographer = PhotographerMapper.toDomainDetails(photographerDto);
      final portfolio = portfolioDto == null
          ? null
          : PhotographerMapper.toDomainPortfolio(portfolioDto);
      final reviews = reviewDtos
          .map(PhotographerMapper.toDomainReview)
          .toList();

      return Result.success(
        PhotographerProfileBundle(
          user: user,
          photographer: photographer,
          portfolio: portfolio,
          reviews: reviews,
        ),
      );
    } catch (_) {
      return Result.failure(
        const Failure(message: 'Failed to load photographer profile'),
      );
    }
  }

  @override
  Future<Result<bool>> isFavorite({
    required String userId,
    required String photographerId,
  }) async {
    try {
      final result = await _remoteDataSource.isFavorite(userId, photographerId);
      return Result.success(result);
    } catch (_) {
      return Result.failure(
        const Failure(message: 'Failed to load favorite status'),
      );
    }
  }

  @override
  Future<Result<void>> setFavorite({
    required String userId,
    required String photographerId,
    required bool isFavorite,
  }) async {
    try {
      await _remoteDataSource.setFavorite(userId, photographerId, isFavorite);
      return Result.success(null);
    } catch (_) {
      return Result.failure(
        const Failure(message: 'Failed to update favorite'),
      );
    }
  }
}
