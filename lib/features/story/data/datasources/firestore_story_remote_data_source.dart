import 'package:laqta/core/utils/legacy_data_compat.dart';
import 'package:laqta/core/models/story_model.dart';
import 'package:laqta/core/security/secure_firestore.dart';
import 'package:laqta/core/services/backend_media_service.dart';
import 'package:laqta/features/story/data/datasources/story_remote_data_source.dart';

class FirestoreStoryRemoteDataSource implements StoryRemoteDataSource {
  final LegacyDataStore _firestore;
  final SecureFirestore _secure;
  final BackendMediaService _backendMediaService;

  FirestoreStoryRemoteDataSource({LegacyDataStore? firestore})
    : _firestore = firestore ?? LegacyDataStore.instance,
      _secure = SecureFirestore(firestore ?? LegacyDataStore.instance),
      _backendMediaService = BackendMediaService();

  CollectionReference<Map<String, dynamic>> get _storiesCollection =>
      _firestore.collection('stories');

  @override
  Future<void> createStory(StoryModel story) async {
    await _secure.guard(
      () => _storiesCollection.doc(story.storyId).set(story.toFirestore()),
    );
  }

  @override
  Future<String> uploadStoryImage({
    required String photographerId,
    required String storyId,
    required String filePath,
    required String contentType,
  }) async {
    return _backendMediaService.uploadFile(
      entityType: 'story',
      entityId: photographerId,
      filePath: filePath,
      publicContent: true,
    );
  }
}
