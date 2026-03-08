import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luqta/core/models/story_model.dart';
import 'package:luqta/core/security/secure_firestore.dart';
import 'package:luqta/core/utils/firestore_parsers.dart';

/// Provides Firestore access helpers for stories.
class StoryService {
  StoryService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _secure = SecureFirestore(firestore ?? FirebaseFirestore.instance);

  final FirebaseFirestore _firestore;
  final SecureFirestore _secure;

  Future<List<StoryModel>> fetchActiveStories({int limit = 50}) async {
    final snapshot = await _secure.guard(
      () => _firestore
          .collection('stories')
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get(),
    );

    return snapshot.docs
        .map(StoryModel.fromFirestore)
        .where((story) => story.isActive)
        .toList();
  }

  Future<void> recordStoryView({
    required String storyId,
    required String userId,
  }) async {
    if (storyId.isEmpty || userId.isEmpty) return;

    try {
      final userDoc = await _secure.guard(
        () => _firestore.collection('users').doc(userId).get(),
      );
      final userData = firestoreMap(userDoc.data());
      final userName = readString(userData, 'name', defaultValue: 'Unknown');

      final viewRef = _firestore
          .collection('stories')
          .doc(storyId)
          .collection('views')
          .doc(userId);

      await _secure.guard(
        () => viewRef.set(
          StoryView(
            userId: userId,
            userName: userName,
            viewedAt: DateTime.now(),
          ).toMap(),
        ),
      );
    } catch (_) {
      // Story views are best-effort.
    }
  }
}
