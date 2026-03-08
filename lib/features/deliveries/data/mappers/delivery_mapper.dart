import 'package:luqta/features/deliveries/domain/entities/delivery.dart';
import '../dtos/delivery_dto.dart';

class DeliveryMapper {
  static Delivery toDomain(DeliveryDto dto) {
    return Delivery(
      id: dto.id,
      bookingId: dto.bookingId,
      photographerId: dto.photographerId,
      customerId: dto.customerId,
      status: dto.status,
      photoUrls: dto.photoUrls,
      videoUrls: dto.videoUrls,
      otherUrls: dto.otherUrls,
      note: dto.note,
      revisionNote: dto.revisionNote,
      revisionCount: dto.revisionCount,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }

  static DeliveryDto toDto(Delivery delivery) {
    return DeliveryDto(
      id: delivery.id,
      bookingId: delivery.bookingId,
      photographerId: delivery.photographerId,
      customerId: delivery.customerId,
      status: delivery.status,
      photoUrls: delivery.photoUrls,
      videoUrls: delivery.videoUrls,
      otherUrls: delivery.otherUrls,
      note: delivery.note,
      revisionNote: delivery.revisionNote,
      revisionCount: delivery.revisionCount,
      createdAt: delivery.createdAt,
      updatedAt: delivery.updatedAt,
    );
  }
}
