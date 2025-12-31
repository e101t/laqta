import '../repositories/booking_repository.dart';

class GenerateBookingId {
  final BookingRepository _repository;

  const GenerateBookingId(this._repository);

  String call() => _repository.generateBookingId();
}
