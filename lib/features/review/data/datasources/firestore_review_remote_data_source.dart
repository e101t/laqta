import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luqta/core/security/secure_firestore.dart';
import 'package:luqta/features/review/data/datasources/review_remote_data_source.dart';
import 'package:luqta/features/review/data/dtos/review_dto.dart';

class FirestoreReviewRemoteDataSource implements ReviewRemoteDataSource {
  final FirebaseFirestore _firestore;
  final SecureFirestore _secure;

  FirestoreReviewRemoteDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _secure = SecureFirestore(firestore ?? FirebaseFirestore.instance);

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('reviews');

  @override
  Future<void> submitReview(ReviewDto review) async {
    await _secure.guard(() => _collection.add(review.toMap()));
  }
}
