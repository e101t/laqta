import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luqta/core/models/story_model.dart';

/// Provides Firestore access helpers for stories.
class StoryService {
  StoryService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<List<StoryModel>> fetchActiveStories({int limit = 50}) async {
    final snapshot = await _firestore
        .collection('stories')
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map(StoryModel.fromFirestore)
        .where((story) => story.isActive)
        .toList();
  }

  Future<void> recordStoryView({
    required String storyId,
    required String userId,
  }) async {
    if (userId.isEmpty) return;

    final userDoc = await _firestore.collection('users').doc(userId).get();
    final userName = userDoc.data()?['name'] ?? 'Unknown';

    final storyRef = _firestore.collection('stories').doc(storyId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(storyRef);
      if (!snapshot.exists) return;

      final data = snapshot.data();
      final currentViews = (data?['views'] as List<dynamic>? ?? [])
          .map<Map<String, dynamic>>(
            (view) => Map<String, dynamic>.from(view as Map<String, dynamic>),
          )
          .toList();

      final alreadyViewed = currentViews.any(
        (view) => (view['userId'] as String?) == userId,
      );

      if (alreadyViewed) {
        return;
      }

      final view = StoryView(
        userId: userId,
        userName: userName,
        viewedAt: DateTime.now(),
      ).toMap();

      currentViews.add(view);
      transaction.update(storyRef, {'views': currentViews});
    });
  }
}
