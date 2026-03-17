import 'package:laqta/core/domain/result/result.dart';
import '../entities/photographer_profile_bundle.dart';

abstract class PhotographerRepository {
  Future<Result<PhotographerProfileBundle>> getPhotographerProfile({
    required String photographerId,
  });

  Future<Result<bool>> isFavorite({
    required String userId,
    required String photographerId,
  });

  Future<Result<void>> setFavorite({
    required String userId,
    required String photographerId,
    required bool isFavorite,
  });
}
