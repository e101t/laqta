import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:luqta/core/constants/app_constants.dart';
import 'package:luqta/core/security/secure_firestore.dart';
import 'package:luqta/features/booking/data/datasources/booking_remote_data_source.dart';
import 'package:luqta/features/booking/data/dtos/booking_dto.dart';

class FirestoreBookingRemoteDataSource implements BookingRemoteDataSource {
  final FirebaseFirestore _firestore;
  final SecureFirestore _secure;

  FirestoreBookingRemoteDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _secure = SecureFirestore(firestore ?? FirebaseFirestore.instance);

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('bookings');

  @override
  Future<List<BookingDto>> getMyBookings(String userId) async {
    Query<Map<String, dynamic>> query =
        _collection.where('customerId', isEqualTo: userId);
    if (!kDebugMode) {
      query = query.orderBy('createdAt', descending: true);
    }
    final snapshot = await _secure.guard(
      () => query.limit(AppConstants.queryLimit).get(),
    );

    return snapshot.docs.map(BookingDto.fromFirestore).toList();
  }

  @override
  Future<BookingDto> getBookingById(String bookingId) async {
    final doc = await _secure.guard(() => _collection.doc(bookingId).get());
    if (!doc.exists) {
      throw StateError('Booking not found');
    }
    return BookingDto.fromFirestore(doc);
  }

  @override
  Future<void> createBooking(BookingDto booking) async {
    final docRef = booking.id.isEmpty
        ? _collection.doc()
        : _collection.doc(booking.id);
    await _secure.guard(() => docRef.set(booking.toMap()));
  }

  @override
  Future<void> updateBookingStatus(String bookingId, String status) async {
    await _secure.guard(
      () => _collection.doc(bookingId).update({
        'status': status,
        'updatedAt': Timestamp.now(),
      }),
    );
  }

  @override
  Future<void> updateBooking(
    String bookingId,
    Map<String, dynamic> updates,
  ) async {
    final patched = Map<String, dynamic>.from(updates)
      ..['updatedAt'] = Timestamp.now();
    await _secure.guard(() => _collection.doc(bookingId).update(patched));
  }

  @override
  String generateBookingId() {
    return _collection.doc().id;
  }
}
