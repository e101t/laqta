import 'package:laqta/core/domain/result/result.dart';
import '../entities/trust_stats.dart';
import '../repositories/trust_repository.dart';

class GetTrustStats {
  final TrustRepository _repository;

  const GetTrustStats(this._repository);

  Future<Result<TrustStats?>> call(String photographerId) {
    return _repository.getTrustStats(photographerId);
  }
}
