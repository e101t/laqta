import 'package:laqta/core/domain/result/result.dart';
import '../entities/dashboard_booking.dart';
import '../repositories/dashboard_repository.dart';

class GetPhotographerBookings {
  final DashboardRepository _repository;

  const GetPhotographerBookings(this._repository);

  Future<Result<List<DashboardBooking>>> call({
    required String photographerId,
  }) {
    return _repository.getPhotographerBookings(photographerId: photographerId);
  }
}
