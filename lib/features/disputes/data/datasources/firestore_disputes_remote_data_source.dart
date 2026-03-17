import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laqta/core/constants/app_constants.dart';
import 'package:laqta/core/security/secure_firestore.dart';
import 'package:laqta/features/disputes/data/datasources/disputes_remote_data_source.dart';
import 'package:laqta/features/disputes/data/dtos/dispute_dto.dart';

class FirestoreDisputesRemoteDataSource implements DisputesRemoteDataSource {
  final FirebaseFirestore _firestore;
  final SecureFirestore _secure;

  FirestoreDisputesRemoteDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _secure = SecureFirestore(firestore ?? FirebaseFirestore.instance);

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('disputes');

  @override
  Future<DisputeDto?> getDisputeByBooking(String bookingId) async {
    final snapshot = await _secure.guard(
      () => _collection
          .where('bookingId', isEqualTo: bookingId)
          .limit(1)
          .get(),
    );
    if (snapshot.docs.isEmpty) {
      return null;
    }
    return DisputeDto.fromFirestore(snapshot.docs.first);
  }

  @override
  Future<List<DisputeDto>> getDisputesForUser(String userId) async {
    final customerSnapshot = await _secure.guard(
      () => _collection
          .where('customerId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(AppConstants.queryLimit)
          .get(),
    );

    final photographerSnapshot = await _secure.guard(
      () => _collection
          .where('photographerId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(AppConstants.queryLimit)
          .get(),
    );

    final combined = <String, DisputeDto>{};
    for (final doc in customerSnapshot.docs) {
      combined[doc.id] = DisputeDto.fromFirestore(doc);
    }
    for (final doc in photographerSnapshot.docs) {
      combined[doc.id] = DisputeDto.fromFirestore(doc);
    }

    return combined.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<List<DisputeDto>> getOpenDisputes() async {
    final snapshot = await _secure.guard(
      () => _collection
          .where('status', isEqualTo: 'open')
          .orderBy('createdAt', descending: true)
          .limit(AppConstants.queryLimit)
          .get(),
    );
    return snapshot.docs.map(DisputeDto.fromFirestore).toList();
  }

  @override
  Future<void> createDispute(DisputeDto dispute) async {
    await _secure.guard(() => _collection.add(dispute.toMap()));
  }

  @override
  Future<void> updateDispute(DisputeDto dispute) async {
    await _secure.guard(
      () => _collection.doc(dispute.id).update(dispute.toMap()),
    );
  }
}
