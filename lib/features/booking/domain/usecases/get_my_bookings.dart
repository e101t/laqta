import 'package:luqta/core/domain/result/result.dart';
import '../entities/booking.dart';
import '../repositories/booking_repository.dart';

class GetMyBookings {
  final BookingRepository _repository;

  const GetMyBookings(this._repository);

  Future<Result<List<Booking>>> call({required String userId}) {
    return _repository.getMyBookings(userId: userId);
  }
}
