import 'package:luqta/core/domain/result/result.dart';
import '../entities/home_photographer.dart';
import '../repositories/home_repository.dart';

class GetHomePhotographers {
  final HomeRepository _repository;

  const GetHomePhotographers(this._repository);

  Future<Result<List<HomePhotographer>>> call({
    String? governorate,
    String? specialty,
    String? gender,
    double minRating = 0,
    int limit = 50,
  }) {
    return _repository.getPhotographers(
      governorate: governorate,
      specialty: specialty,
      gender: gender,
      minRating: minRating,
      limit: limit,
    );
  }
}
