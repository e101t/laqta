import 'package:laqta/features/trust/domain/entities/trust_stats.dart';
import '../dtos/trust_stats_dto.dart';

class TrustStatsMapper {
  static TrustStats toDomain(TrustStatsDto dto) {
    return TrustStats(
      photographerId: dto.photographerId,
      reviewCount: dto.reviewCount,
      sumQuality: dto.sumQuality,
      sumCommunication: dto.sumCommunication,
      sumOnTime: dto.sumOnTime,
      sumDelivery: dto.sumDelivery,
      completedBookings: dto.completedBookings,
      canceledByPhotographer: dto.canceledByPhotographer,
      disputesCount: dto.disputesCount,
      updatedAt: dto.updatedAt,
    );
  }

  static TrustStatsDto toDto(TrustStats stats) {
    return TrustStatsDto(
      photographerId: stats.photographerId,
      reviewCount: stats.reviewCount,
      sumQuality: stats.sumQuality,
      sumCommunication: stats.sumCommunication,
      sumOnTime: stats.sumOnTime,
      sumDelivery: stats.sumDelivery,
      completedBookings: stats.completedBookings,
      canceledByPhotographer: stats.canceledByPhotographer,
      disputesCount: stats.disputesCount,
      updatedAt: stats.updatedAt,
    );
  }
}
