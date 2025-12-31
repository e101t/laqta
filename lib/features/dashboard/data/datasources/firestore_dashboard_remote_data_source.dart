import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luqta/features/booking/data/dtos/booking_dto.dart';
import 'package:luqta/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:luqta/features/profile/data/dtos/user_profile_dto.dart';

class FirestoreDashboardRemoteDataSource implements DashboardRemoteDataSource {
  final FirebaseFirestore _firestore;

  FirestoreDashboardRemoteDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _bookingsCollection =>
      _firestore.collection('bookings');

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  @override
  Future<List<BookingDto>> getPhotographerBookings(
    String photographerId,
  ) async {
    final snapshot = await _bookingsCollection
        .where('photographerId', isEqualTo: photographerId)
        .get();
    return snapshot.docs.map(BookingDto.fromFirestore).toList();
  }

  @override
  Future<List<UserProfileDto>> getUsersByIds(List<String> userIds) async {
    if (userIds.isEmpty) return <UserProfileDto>[];
    const chunkSize = 10;
    final results = <UserProfileDto>[];

    for (var i = 0; i < userIds.length; i += chunkSize) {
      final chunk = userIds.skip(i).take(chunkSize).toList();
      final snapshot = await _usersCollection
          .where(FieldPath.documentId, whereIn: chunk)
          .get();
      results.addAll(snapshot.docs.map(UserProfileDto.fromFirestore));
    }

    return results;
  }
}
