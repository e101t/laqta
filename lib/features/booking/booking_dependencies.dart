import 'package:luqta/features/booking/data/datasources/booking_remote_data_source.dart';
import 'package:flutter/foundation.dart';
import 'package:luqta/features/booking/data/datasources/firestore_booking_remote_data_source.dart';
import 'package:luqta/features/booking/data/repositories/booking_repository_impl.dart';
import 'package:luqta/features/booking/domain/repositories/booking_repository.dart';
import 'package:luqta/features/booking/domain/usecases/create_booking.dart';
import 'package:luqta/features/booking/domain/usecases/generate_booking_id.dart';
import 'package:luqta/features/booking/domain/usecases/get_booking_by_id.dart';
import 'package:luqta/features/booking/domain/usecases/get_my_bookings.dart';
import 'package:luqta/features/booking/domain/usecases/update_booking_status.dart';
import 'package:luqta/features/booking/domain/usecases/update_booking.dart';

class BookingDependencies {
  static final BookingRemoteDataSource _remoteDataSource =
      FirestoreBookingRemoteDataSource();
  static BookingRepository? _repositoryOverride;

  @visibleForTesting
  static void setRepositoryOverride(BookingRepository? repository) {
    _repositoryOverride = repository;
  }

  static BookingRepository get _repository =>
      _repositoryOverride ?? BookingRepositoryImpl(_remoteDataSource);

  static GetMyBookings getMyBookings() => GetMyBookings(_repository);

  static GetBookingById getBookingById() => GetBookingById(_repository);

  static CreateBooking createBooking() => CreateBooking(_repository);

  static UpdateBookingStatus updateBookingStatus() =>
      UpdateBookingStatus(_repository);

  static UpdateBooking updateBooking() => UpdateBooking(_repository);

  static GenerateBookingId generateBookingId() =>
      GenerateBookingId(_repository);
}
