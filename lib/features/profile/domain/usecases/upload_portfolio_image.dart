import 'package:luqta/core/domain/result/result.dart';
import '../repositories/profile_repository.dart';

class UploadPortfolioImage {
  final ProfileRepository _repository;

  const UploadPortfolioImage(this._repository);

  Future<Result<String>> call({
    required String photographerId,
    required String filePath,
  }) {
    return _repository.uploadPortfolioImage(
      photographerId: photographerId,
      filePath: filePath,
    );
  }
}
