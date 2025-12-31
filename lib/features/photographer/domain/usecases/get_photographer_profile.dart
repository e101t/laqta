import 'package:luqta/core/domain/result/result.dart';
import '../entities/photographer_profile_bundle.dart';
import '../repositories/photographer_repository.dart';

class GetPhotographerProfile {
  final PhotographerRepository _repository;

  const GetPhotographerProfile(this._repository);

  Future<Result<PhotographerProfileBundle>> call({
    required String photographerId,
  }) {
    return _repository.getPhotographerProfile(photographerId: photographerId);
  }
}
