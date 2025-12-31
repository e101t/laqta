import 'package:luqta/features/loyalty/data/dtos/loyalty_points_dto.dart';
import 'package:luqta/features/loyalty/domain/entities/loyalty_points.dart';

class LoyaltyMapper {
  static LoyaltyPoints toDomain(LoyaltyPointsDto dto) {
    return LoyaltyPoints(
      userId: dto.id,
      totalPoints: dto.totalPoints,
      availablePoints: dto.availablePoints,
      usedPoints: dto.usedPoints,
      tier: dto.tier,
      lastUpdated: dto.lastUpdated,
      transactions: dto.transactions
          .map(
            (transaction) => PointTransaction(
              transactionId: transaction.transactionId,
              points: transaction.points,
              type: transaction.type,
              source: transaction.source,
              description: transaction.description,
              createdAt: transaction.createdAt,
            ),
          )
          .toList(),
    );
  }

  static LoyaltyPointsDto toDto(LoyaltyPoints points) {
    return LoyaltyPointsDto(
      id: points.userId,
      totalPoints: points.totalPoints,
      availablePoints: points.availablePoints,
      usedPoints: points.usedPoints,
      tier: points.tier,
      lastUpdated: points.lastUpdated,
      transactions: points.transactions
          .map(
            (transaction) => PointTransactionDto(
              transactionId: transaction.transactionId,
              points: transaction.points,
              type: transaction.type,
              source: transaction.source,
              description: transaction.description,
              createdAt: transaction.createdAt,
            ),
          )
          .toList(),
    );
  }
}
