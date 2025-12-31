import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luqta/features/reels/data/datasources/reels_remote_data_source.dart';
import 'package:luqta/features/reels/data/dtos/comment_dto.dart';
import 'package:luqta/features/reels/data/dtos/reel_dto.dart';

class FirestoreReelsRemoteDataSource implements ReelsRemoteDataSource {
  final FirebaseFirestore _firestore;

  FirestoreReelsRemoteDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _reelsCollection =>
      _firestore.collection('reels');

  CollectionReference<Map<String, dynamic>> get _commentsCollection =>
      _firestore.collection('comments');

  @override
  Future<List<ReelDto>> getReels() async {
    final snapshot = await _reelsCollection
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map(ReelDto.fromFirestore).toList();
  }

  @override
  Future<void> updateReelCounter({
    required String reelId,
    required String field,
    required int delta,
  }) async {
    await _reelsCollection.doc(reelId).update({
      field: FieldValue.increment(delta),
    });
  }

  @override
  Future<List<CommentDto>> getComments(String reelId) async {
    final snapshot = await _commentsCollection
        .where('reelId', isEqualTo: reelId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map(CommentDto.fromFirestore).toList();
  }

  @override
  Future<void> addComment(CommentDto comment) async {
    await _commentsCollection.add(comment.toMap());
  }
}
