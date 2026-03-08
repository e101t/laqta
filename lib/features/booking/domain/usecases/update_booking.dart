import 'package:luqta/core/domain/result/result.dart';
import '../repositories/booking_repository.dart';

class UpdateBooking {
  final BookingRepository _repository;

  const UpdateBooking(this._repository);

  Future<Result<void>> call({
    required String bookingId,
    required Map<String, dynamic> updates,
  }) {
    return _repository.updateBooking(bookingId: bookingId, updates: updates);
  }
}
