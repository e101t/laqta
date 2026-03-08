import 'package:luqta/features/disputes/domain/entities/dispute.dart';
import '../dtos/dispute_dto.dart';

class DisputeMapper {
  static Dispute toDomain(DisputeDto dto) {
    return Dispute(
      id: dto.id,
      bookingId: dto.bookingId,
      requestId: dto.requestId,
      customerId: dto.customerId,
      photographerId: dto.photographerId,
      openedBy: dto.openedBy,
      reason: dto.reason,
      details: dto.details,
      evidenceUrls: dto.evidenceUrls,
      status: dto.status,
      resolution: dto.resolution,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
      closedAt: dto.closedAt,
      decidedBy: dto.decidedBy,
    );
  }

  static DisputeDto toDto(Dispute dispute) {
    return DisputeDto(
      id: dispute.id,
      bookingId: dispute.bookingId,
      requestId: dispute.requestId,
      customerId: dispute.customerId,
      photographerId: dispute.photographerId,
      openedBy: dispute.openedBy,
      reason: dispute.reason,
      details: dispute.details,
      evidenceUrls: dispute.evidenceUrls,
      status: dispute.status,
      resolution: dispute.resolution,
      createdAt: dispute.createdAt,
      updatedAt: dispute.updatedAt,
      closedAt: dispute.closedAt,
      decidedBy: dispute.decidedBy,
    );
  }
}
