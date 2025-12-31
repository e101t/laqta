import 'package:luqta/core/domain/failures/failure.dart';
import 'package:luqta/core/domain/result/result.dart';
import 'package:luqta/features/booking/data/datasources/booking_remote_data_source.dart';
import 'package:luqta/features/booking/data/mappers/booking_mapper.dart';
import 'package:luqta/features/booking/domain/entities/booking.dart';
import 'package:luqta/features/booking/domain/repositories/booking_repository.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDataSource _remoteDataSource;

  const BookingRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<List<Booking>>> getMyBookings({required String userId}) async {
    try {
      final dtos = await _remoteDataSource.getMyBookings(userId);
      final bookings = dtos.map(BookingMapper.toDomain).toList();
      return Result.success(bookings);
    } catch (_) {
      return Result.failure(const Failure(message: 'Failed to load bookings'));
    }
  }

  @override
  Future<Result<Booking>> getBookingById(String bookingId) async {
    try {
      final dto = await _remoteDataSource.getBookingById(bookingId);
      return Result.success(BookingMapper.toDomain(dto));
    } catch (_) {
      return Result.failure(const Failure(message: 'Failed to load booking'));
    }
  }

  @override
  Future<Result<void>> createBooking(Booking booking) async {
    try {
      final dto = BookingMapper.toDto(booking);
      await _remoteDataSource.createBooking(dto);
      return Result.success(null);
    } catch (_) {
      return Result.failure(const Failure(message: 'Failed to create booking'));
    }
  }

  @override
  Future<Result<void>> updateBookingStatus({
    required String bookingId,
    required String status,
  }) async {
    try {
      await _remoteDataSource.updateBookingStatus(bookingId, status);
      return Result.success(null);
    } catch (_) {
      return Result.failure(
        const Failure(message: 'Failed to update booking status'),
      );
    }
  }

  @override
  String generateBookingId() {
    return _remoteDataSource.generateBookingId();
  }
}
