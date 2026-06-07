import 'package:laqta/core/utils/legacy_data_compat.dart';
import 'package:laqta/core/constants/app_constants.dart';
import 'package:laqta/core/security/secure_firestore.dart';
import 'package:laqta/core/services/backend_media_service.dart';
import 'package:laqta/features/reels/data/datasources/reels_remote_data_source.dart';
import 'package:laqta/features/reels/data/dtos/comment_dto.dart';
import 'package:laqta/features/reels/data/dtos/reel_dto.dart';

class FirestoreReelsRemoteDataSource implements ReelsRemoteDataSource {
  final LegacyDataStore _firestore;
  final SecureFirestore _secure;
  final BackendMediaService _backendMediaService;
  final BackendFunctionClient _functions;

  FirestoreReelsRemoteDataSource({
    LegacyDataStore? firestore,
    BackendFunctionClient? functions,
  }) : _firestore = firestore ?? LegacyDataStore.instance,
       _secure = SecureFirestore(firestore ?? LegacyDataStore.instance),
       _backendMediaService = BackendMediaService(),
       _functions = functions ?? BackendFunctionClient.instance;

  CollectionReference<Map<String, dynamic>> get _reelsCollection =>
      _firestore.collection('reels');

  CollectionReference<Map<String, dynamic>> get _commentsCollection =>
      _firestore.collection('comments');

  @override
  Future<List<ReelDto>> getReels() async {
    final snapshot = await _secure.guard(
      () => _reelsCollection
          .orderBy('createdAt', descending: true)
          .limit(AppConstants.queryLimit)
          .get(),
    );
    return snapshot.docs.map(ReelDto.fromFirestore).toList();
  }

  @override
  Future<void> createReel(ReelDto reel) async {
    await _secure.guard(() => _reelsCollection.doc(reel.id).set(reel.toMap()));
  }

  @override
  Future<void> updateReelCounter({
    required String reelId,
    required String field,
    required int delta,
  }) async {
    if (field == 'likes') {
      final callable = _functions.httpsCallable('updateReelLike');
      await callable.call({'reelId': reelId, 'delta': delta});
      return;
    }
    final callable = _functions.httpsCallable('updateReelCounter');
    await callable.call({'reelId': reelId, 'field': field, 'delta': delta});
  }

  @override
  Future<List<CommentDto>> getComments(String reelId) async {
    final snapshot = await _secure.guard(
      () => _commentsCollection
          .where('reelId', isEqualTo: reelId)
          .orderBy('createdAt', descending: true)
          .limit(AppConstants.queryLimit)
          .get(),
    );
    return snapshot.docs.map(CommentDto.fromFirestore).toList();
  }

  @override
  Future<void> addComment(CommentDto comment) async {
    await _secure.guard(() => _commentsCollection.add(comment.toMap()));
  }

  @override
  Future<String> uploadReelMedia({
    required String photographerId,
    required String reelId,
    required String filePath,
    required String contentType,
  }) async {
    return _backendMediaService.uploadFile(
      entityType: 'reel',
      entityId: photographerId,
      filePath: filePath,
      publicContent: true,
    );
  }
}
