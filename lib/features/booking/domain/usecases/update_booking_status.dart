import 'package:laqta/core/domain/result/result.dart';
import '../repositories/booking_repository.dart';

class UpdateBookingStatus {
  final BookingRepository _repository;

  const UpdateBookingStatus(this._repository);

  Future<Result<void>> call({
    required String bookingId,
    required String status,
  }) {
    return _repository.updateBookingStatus(
      bookingId: bookingId,
      status: status,
    );
  }
}
