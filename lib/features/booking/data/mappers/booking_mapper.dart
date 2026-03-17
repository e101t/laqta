import 'package:laqta/features/booking/data/dtos/booking_dto.dart';
import 'package:laqta/features/booking/domain/entities/booking.dart';

class BookingMapper {
  static Booking toDomain(BookingDto dto) {
    return Booking(
      id: dto.id,
      customerId: dto.customerId,
      photographerId: dto.photographerId,
      requestId: dto.requestId,
      offerId: dto.offerId,
      date: dto.date,
      time: dto.time,
      duration: dto.duration,
      type: dto.type,
      price: dto.price,
      currency: dto.currency,
      status: dto.status,
      payment: BookingPayment(
        status: dto.payment.status,
        intentId: dto.payment.intentId,
        amount: dto.payment.amount,
        paidAt: dto.payment.paidAt,
      ),
      location: BookingLocation(
        lat: dto.location.lat,
        lng: dto.location.lng,
        text: dto.location.text,
      ),
      deliverables: BookingDeliverables(
        photosCount: dto.deliverables.photosCount,
        videoMinutes: dto.deliverables.videoMinutes,
        includesEditing: dto.deliverables.includesEditing,
        includesVideo: dto.deliverables.includesVideo,
        notes: dto.deliverables.notes,
      ),
      notes: dto.notes,
      chatId: dto.chatId,
      deliveryId: dto.deliveryId,
      disputeId: dto.disputeId,
      revisionCount: dto.revisionCount,
      canceledBy: dto.canceledBy,
      timeline: BookingTimeline(
        confirmedAt: dto.timeline.confirmedAt,
        inProgressAt: dto.timeline.inProgressAt,
        deliveredAt: dto.timeline.deliveredAt,
        revisionRequestedAt: dto.timeline.revisionRequestedAt,
        completedAt: dto.timeline.completedAt,
        canceledAt: dto.timeline.canceledAt,
      ),
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }

  static BookingDto toDto(Booking booking) {
    return BookingDto(
      id: booking.id,
      customerId: booking.customerId,
      photographerId: booking.photographerId,
      requestId: booking.requestId,
      offerId: booking.offerId,
      date: booking.date,
      time: booking.time,
      duration: booking.duration,
      type: booking.type,
      price: booking.price,
      currency: booking.currency,
      status: booking.status,
      payment: BookingPaymentDto(
        status: booking.payment.status,
        intentId: booking.payment.intentId,
        amount: booking.payment.amount,
        paidAt: booking.payment.paidAt,
      ),
      location: BookingLocationDto(
        lat: booking.location.lat,
        lng: booking.location.lng,
        text: booking.location.text,
      ),
      deliverables: BookingDeliverablesDto(
        photosCount: booking.deliverables.photosCount,
        videoMinutes: booking.deliverables.videoMinutes,
        includesEditing: booking.deliverables.includesEditing,
        includesVideo: booking.deliverables.includesVideo,
        notes: booking.deliverables.notes,
      ),
      notes: booking.notes,
      chatId: booking.chatId,
      deliveryId: booking.deliveryId,
      disputeId: booking.disputeId,
      revisionCount: booking.revisionCount,
      canceledBy: booking.canceledBy,
      timeline: BookingTimelineDto(
        confirmedAt: booking.timeline.confirmedAt,
        inProgressAt: booking.timeline.inProgressAt,
        deliveredAt: booking.timeline.deliveredAt,
        revisionRequestedAt: booking.timeline.revisionRequestedAt,
        completedAt: booking.timeline.completedAt,
        canceledAt: booking.timeline.canceledAt,
      ),
      createdAt: booking.createdAt,
      updatedAt: booking.updatedAt,
    );
  }
}
