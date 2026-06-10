import 'package:laqta/core/models/booking_model.dart';
import 'package:laqta/features/booking/domain/entities/booking.dart' as domain;

class BookingPresentationMapper {
  static BookingModel toModel(domain.Booking booking) {
    return BookingModel(
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
      payment: PaymentInfo(
        status: booking.payment.status,
        intentId: booking.payment.intentId,
        amount: booking.payment.amount,
        paidAt: booking.payment.paidAt,
      ),
      location: LocationInfo(
        lat: booking.location.lat,
        lng: booking.location.lng,
        text: booking.location.text,
      ),
      deliverables: DeliverablesInfo(
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
      timeline: BookingTimeline(
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

  static domain.Booking toDomain(BookingModel model) {
    return domain.Booking(
      id: model.id,
      customerId: model.customerId,
      photographerId: model.photographerId,
      requestId: model.requestId,
      offerId: model.offerId,
      date: model.date,
      time: model.time,
      duration: model.duration,
      type: model.type,
      price: model.price,
      currency: model.currency,
      status: model.status,
      payment: domain.BookingPayment(
        status: model.payment.status,
        intentId: model.payment.intentId,
        amount: model.payment.amount,
        paidAt: model.payment.paidAt,
      ),
      location: domain.BookingLocation(
        lat: model.location.lat,
        lng: model.location.lng,
        text: model.location.text,
      ),
      deliverables: domain.BookingDeliverables(
        photosCount: model.deliverables.photosCount,
        videoMinutes: model.deliverables.videoMinutes,
        includesEditing: model.deliverables.includesEditing,
        includesVideo: model.deliverables.includesVideo,
        notes: model.deliverables.notes,
      ),
      notes: model.notes,
      chatId: model.chatId,
      deliveryId: model.deliveryId,
      disputeId: model.disputeId,
      revisionCount: model.revisionCount,
      canceledBy: model.canceledBy,
      timeline: domain.BookingTimeline(
        confirmedAt: model.timeline.confirmedAt,
        inProgressAt: model.timeline.inProgressAt,
        deliveredAt: model.timeline.deliveredAt,
        revisionRequestedAt: model.timeline.revisionRequestedAt,
        completedAt: model.timeline.completedAt,
        canceledAt: model.timeline.canceledAt,
      ),
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }
}
