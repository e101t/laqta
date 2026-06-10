import 'package:laqta/core/domain/result/result.dart';
import '../entities/loyalty_points.dart';

abstract class LoyaltyRepository {
  Future<Result<LoyaltyPoints>> getOrCreateLoyaltyPoints({
    required String userId,
  });
}
