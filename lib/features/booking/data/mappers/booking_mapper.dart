import 'package:luqta/features/booking/data/dtos/booking_dto.dart';
import 'package:luqta/features/booking/domain/entities/booking.dart';

class BookingMapper {
  static Booking toDomain(BookingDto dto) {
    return Booking(
      id: dto.id,
      customerId: dto.customerId,
      photographerId: dto.photographerId,
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
      notes: dto.notes,
      chatId: dto.chatId,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }

  static BookingDto toDto(Booking booking) {
    return BookingDto(
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
      notes: booking.notes,
      chatId: booking.chatId,
      createdAt: booking.createdAt,
      updatedAt: booking.updatedAt,
    );
  }
}
