import 'package:luqta/core/domain/result/result.dart';
import '../entities/booking.dart';
import '../repositories/booking_repository.dart';

class GetBookingById {
  final BookingRepository _repository;

  const GetBookingById(this._repository);

  Future<Result<Booking>> call(String bookingId) {
    return _repository.getBookingById(bookingId);
  }
}
