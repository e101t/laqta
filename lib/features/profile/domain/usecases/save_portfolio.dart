import 'package:luqta/core/domain/result/result.dart';
import '../entities/portfolio.dart';
import '../repositories/profile_repository.dart';

class SavePortfolio {
  final ProfileRepository _repository;

  const SavePortfolio(this._repository);

  Future<Result<void>> call({
    required String photographerId,
    required List<PortfolioImage> images,
  }) {
    return _repository.savePortfolio(
      photographerId: photographerId,
      images: images,
    );
  }
}
