import 'package:cloud_firestore/cloud_firestore.dart';

/// Handles follow/unfollow workflows against Firestore.
class FollowService {
  FollowService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('following');

  Future<Set<String>> fetchFollowing(String userId) async {
    if (userId.isEmpty) return {};

    final snapshot = await _collection
        .where('followerId', isEqualTo: userId)
        .get();

    return snapshot.docs
        .map((doc) => doc.data()['followingId'] as String? ?? '')
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
      await _collection.doc(_docId(followerId, targetId)).set({
        'followerId': followerId,
        'followingId': targetId,
        'followedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
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
    final doc = await docRef.get();
    if (doc.exists) {
      await docRef.delete();
      return;
    }

    final snapshot = await _collection
        .where('followerId', isEqualTo: followerId)
        .where('followingId', isEqualTo: targetId)
        .limit(10)
        .get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}
