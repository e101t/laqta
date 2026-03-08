import 'package:luqta/core/domain/result/result.dart';
import '../entities/booking.dart';

abstract class BookingRepository {
  Future<Result<List<Booking>>> getMyBookings({required String userId});

  Future<Result<Booking>> getBookingById(String bookingId);

  Future<Result<void>> createBooking(Booking booking);

  Future<Result<void>> updateBookingStatus({
    required String bookingId,
    required String status,
  });

  Future<Result<void>> updateBooking({
    required String bookingId,
    required Map<String, dynamic> updates,
  });

  String generateBookingId();
}
