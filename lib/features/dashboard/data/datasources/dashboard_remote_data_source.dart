import 'package:laqta/features/booking/data/dtos/booking_dto.dart';
import 'package:laqta/features/profile/data/dtos/user_profile_dto.dart';

abstract class DashboardRemoteDataSource {
  Future<List<BookingDto>> getPhotographerBookings(String photographerId);

  Future<List<UserProfileDto>> getUsersByIds(List<String> userIds);
}
