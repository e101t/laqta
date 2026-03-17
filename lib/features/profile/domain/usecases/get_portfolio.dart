import 'package:laqta/core/domain/result/result.dart';
import '../entities/portfolio.dart';
import '../repositories/profile_repository.dart';

class GetPortfolio {
  final ProfileRepository _repository;

  const GetPortfolio(this._repository);

  Future<Result<Portfolio?>> call({required String photographerId}) {
    return _repository.getPortfolio(photographerId: photographerId);
  }
}
