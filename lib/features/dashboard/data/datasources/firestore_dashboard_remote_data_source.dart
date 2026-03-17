import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laqta/core/constants/app_constants.dart';
import 'package:laqta/core/security/secure_firestore.dart';
import 'package:laqta/features/booking/data/dtos/booking_dto.dart';
import 'package:laqta/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:laqta/features/profile/data/dtos/user_profile_dto.dart';

class FirestoreDashboardRemoteDataSource implements DashboardRemoteDataSource {
  final FirebaseFirestore _firestore;
  final SecureFirestore _secure;

  FirestoreDashboardRemoteDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _secure = SecureFirestore(firestore ?? FirebaseFirestore.instance);

  CollectionReference<Map<String, dynamic>> get _bookingsCollection =>
      _firestore.collection('bookings');

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users_public');

  @override
  Future<List<BookingDto>> getPhotographerBookings(
    String photographerId,
  ) async {
    final snapshot = await _secure.guard(
      () => _bookingsCollection
          .where('photographerId', isEqualTo: photographerId)
          .limit(AppConstants.queryLimit)
          .get(),
    );
    return snapshot.docs.map(BookingDto.fromFirestore).toList();
  }

  @override
  Future<List<UserProfileDto>> getUsersByIds(List<String> userIds) async {
    if (userIds.isEmpty) return <UserProfileDto>[];
    const chunkSize = 10;
    final results = <UserProfileDto>[];

    for (var i = 0; i < userIds.length; i += chunkSize) {
      final chunk = userIds.skip(i).take(chunkSize).toList();
      final snapshot = await _secure.guard(
        () =>
            _usersCollection.where(FieldPath.documentId, whereIn: chunk).get(),
      );
      results.addAll(snapshot.docs.map(UserProfileDto.fromFirestore));
    }

    return results;
  }
}
