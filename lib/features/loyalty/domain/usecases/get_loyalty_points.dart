import 'package:luqta/core/domain/result/result.dart';
import '../entities/loyalty_points.dart';
import '../repositories/loyalty_repository.dart';

class GetLoyaltyPoints {
  final LoyaltyRepository _repository;

  const GetLoyaltyPoints(this._repository);

  Future<Result<LoyaltyPoints>> call({required String userId}) {
    return _repository.getOrCreateLoyaltyPoints(userId: userId);
  }
}
