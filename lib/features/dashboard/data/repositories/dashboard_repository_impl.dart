import 'package:laqta/core/domain/failures/failure.dart';
import 'package:laqta/core/domain/result/result.dart';
import 'package:laqta/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:laqta/features/dashboard/data/mappers/dashboard_mapper.dart';
import 'package:laqta/features/dashboard/domain/entities/dashboard_booking.dart';
import 'package:laqta/features/dashboard/domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource _remoteDataSource;

  const DashboardRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<List<DashboardBooking>>> getPhotographerBookings({
    required String photographerId,
  }) async {
    try {
      final bookingDtos = await _remoteDataSource.getPhotographerBookings(
        photographerId,
      );
      final customerIds = bookingDtos
          .map((booking) => booking.customerId)
          .where((id) => id.isNotEmpty)
          .toSet()
          .toList();
      final users = await _remoteDataSource.getUsersByIds(customerIds);
      final userMap = {for (final user in users) user.id: user};

      final bookings = <DashboardBooking>[];
      for (final booking in bookingDtos) {
        final customerName = userMap[booking.customerId]?.name ?? 'Unknown';
        bookings.add(DashboardMapper.toDomain(booking, customerName));
      }

      return Result.success(bookings);
    } catch (_) {
      return Result.failure(
        const Failure(message: 'Failed to load dashboard bookings'),
      );
    }
  }
}
