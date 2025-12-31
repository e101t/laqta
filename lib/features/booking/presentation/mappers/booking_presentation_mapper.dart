import 'package:luqta/core/models/booking_model.dart';
import 'package:luqta/features/booking/domain/entities/booking.dart';

class BookingPresentationMapper {
  static BookingModel toModel(Booking booking) {
    return BookingModel(
      id: booking.id,
      customerId: booking.customerId,
      photographerId: booking.photographerId,
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
      notes: booking.notes,
      chatId: booking.chatId,
      createdAt: booking.createdAt,
      updatedAt: booking.updatedAt,
    );
  }

  static Booking toDomain(BookingModel model) {
    return Booking(
      id: model.id,
      customerId: model.customerId,
      photographerId: model.photographerId,
      date: model.date,
      time: model.time,
      duration: model.duration,
      type: model.type,
      price: model.price,
      currency: model.currency,
      status: model.status,
      payment: BookingPayment(
        status: model.payment.status,
        intentId: model.payment.intentId,
        amount: model.payment.amount,
        paidAt: model.payment.paidAt,
      ),
      location: BookingLocation(
        lat: model.location.lat,
        lng: model.location.lng,
        text: model.location.text,
      ),
      notes: model.notes,
      chatId: model.chatId,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }
}
