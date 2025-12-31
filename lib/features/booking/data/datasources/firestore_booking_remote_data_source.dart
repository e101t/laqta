import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luqta/features/booking/data/datasources/booking_remote_data_source.dart';
import 'package:luqta/features/booking/data/dtos/booking_dto.dart';

class FirestoreBookingRemoteDataSource implements BookingRemoteDataSource {
  final FirebaseFirestore _firestore;

  FirestoreBookingRemoteDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('bookings');

  @override
  Future<List<BookingDto>> getMyBookings(String userId) async {
    final snapshot = await _collection
        .where('customerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map(BookingDto.fromFirestore).toList();
  }

  @override
  Future<BookingDto> getBookingById(String bookingId) async {
    final doc = await _collection.doc(bookingId).get();
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
    await docRef.set(booking.toMap());
  }

  @override
  Future<void> updateBookingStatus(String bookingId, String status) async {
    await _collection.doc(bookingId).update({
      'status': status,
      'updatedAt': Timestamp.now(),
    });
  }

  @override
  String generateBookingId() {
    return _collection.doc().id;
  }
}
