import 'package:luqta/features/booking/data/dtos/booking_dto.dart';

abstract class BookingRemoteDataSource {
  Future<List<BookingDto>> getMyBookings(String userId);

  Future<BookingDto> getBookingById(String bookingId);

  Future<void> createBooking(BookingDto booking);

  Future<void> updateBookingStatus(String bookingId, String status);

  Future<void> updateBooking(String bookingId, Map<String, dynamic> updates);

  String generateBookingId();
}
