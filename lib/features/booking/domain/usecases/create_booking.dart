import 'package:laqta/core/domain/result/result.dart';
import '../entities/booking.dart';
import '../repositories/booking_repository.dart';

class CreateBooking {
  final BookingRepository _repository;

  const CreateBooking(this._repository);

  Future<Result<void>> call(Booking booking) {
    return _repository.createBooking(booking);
  }
}
