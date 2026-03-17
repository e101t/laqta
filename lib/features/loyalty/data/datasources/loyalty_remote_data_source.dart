import 'package:laqta/features/loyalty/data/dtos/loyalty_points_dto.dart';

abstract class LoyaltyRemoteDataSource {
  Future<LoyaltyPointsDto?> getLoyaltyPoints(String userId);

  Future<void> saveLoyaltyPoints(String userId, LoyaltyPointsDto points);
}
