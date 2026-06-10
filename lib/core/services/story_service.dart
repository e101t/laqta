import 'package:laqta/core/utils/legacy_data_compat.dart';
import 'package:laqta/core/models/story_model.dart';
import 'package:laqta/core/security/secure_firestore.dart';
import 'package:laqta/core/services/backend_api_client.dart';
import 'package:laqta/core/utils/firestore_parsers.dart';

class StoryService {
  StoryService({LegacyDataStore? firestore, BackendApiClient? apiClient})
    : _firestore = firestore ?? LegacyDataStore.instance,
      _secure = SecureFirestore(firestore ?? LegacyDataStore.instance),
      _apiClient = apiClient ?? BackendApiClient();

  final LegacyDataStore _firestore;
  final SecureFirestore _secure;
  final BackendApiClient _apiClient;

  Future<List<StoryModel>> fetchActiveStories({int limit = 50}) async {
    final firestoreStories = await _fetchFirestoreStories(limit: limit);

    try {
      final response = await _apiClient.get('/stories?limit=$limit');
      final payload = response as Map<String, dynamic>;
      final storiesPayload =
          (payload['stories'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>() ??
          const Iterable<Map<String, dynamic>>.empty();
      final backendStories = storiesPayload
          .map(StoryModel.fromJson)
          .where((story) => story.isActive)
          .toList();

      if (backendStories.isEmpty) {
        return firestoreStories;
      }

      final merged = <String, StoryModel>{
        for (final story in backendStories) story.storyId: story,
      };
      for (final story in firestoreStories) {
        merged.putIfAbsent(story.storyId, () => story);
      }

      final stories = merged.values.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return stories;
    } on BackendApiException catch (error) {
      if (error.statusCode == 401 || error.statusCode == 403) {
        return firestoreStories;
      }
      return firestoreStories;
    } catch (_) {
      return firestoreStories;
    }
  }

  Future<void> recordStoryView({
    required String storyId,
    required String userId,
  }) async {
    if (storyId.isEmpty || userId.isEmpty) return;

    try {
      await _apiClient.post('/stories/$storyId/views');
      return;
    } on BackendApiException catch (error) {
      if (error.statusCode != 404) {
        return;
      }
    } catch (_) {
      return;
    }

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

  Future<List<StoryModel>> _fetchFirestoreStories({required int limit}) async {
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
}
