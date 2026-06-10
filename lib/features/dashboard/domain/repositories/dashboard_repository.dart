import 'package:laqta/core/domain/result/result.dart';
import '../entities/dashboard_booking.dart';

abstract class DashboardRepository {
  Future<Result<List<DashboardBooking>>> getPhotographerBookings({
    required String photographerId,
  });
}
