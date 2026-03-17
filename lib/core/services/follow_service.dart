import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laqta/core/constants/app_constants.dart';
import 'package:laqta/core/security/secure_firestore.dart';
import 'package:laqta/core/utils/firestore_parsers.dart';

/// Handles follow/unfollow workflows against Firestore.
class FollowService {
  FollowService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _secure = SecureFirestore(firestore ?? FirebaseFirestore.instance);

  final FirebaseFirestore _firestore;
  final SecureFirestore _secure;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('following');

  Future<Set<String>> fetchFollowing(String userId) async {
    if (userId.isEmpty) return {};

    final snapshot = await _secure.guard(
      () => _collection
          .where('followerId', isEqualTo: userId)
          .limit(AppConstants.queryLimit)
          .get(),
    );

    return snapshot.docs
        .map((doc) => readString(doc.data(), 'followingId'))
        .where((id) => id.isNotEmpty)
        .toSet();
  }

  Future<void> setFollowStatus({
    required String followerId,
    required String targetId,
    required bool follow,
  }) async {
    if (followerId.isEmpty || targetId.isEmpty) return;

    if (follow) {
      await _secure.guard(
        () => _collection.doc(_docId(followerId, targetId)).set({
          'followerId': followerId,
          'followingId': targetId,
          'followedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true)),
      );
    } else {
      await _deleteFollowDocuments(followerId, targetId);
    }
  }

  String _docId(String followerId, String targetId) {
    return '${followerId}_$targetId';
  }

  Future<void> _deleteFollowDocuments(
    String followerId,
    String targetId,
  ) async {
    final docRef = _collection.doc(_docId(followerId, targetId));
    final doc = await _secure.guard(() => docRef.get());
    if (doc.exists) {
      await _secure.guard(() => docRef.delete());
      return;
    }

    final snapshot = await _secure.guard(
      () => _collection
          .where('followerId', isEqualTo: followerId)
          .where('followingId', isEqualTo: targetId)
          .limit(10)
          .get(),
    );
    for (final doc in snapshot.docs) {
      await _secure.guard(() => doc.reference.delete());
    }
  }
}
