import 'package:laqta/core/utils/legacy_data_compat.dart';
import 'package:laqta/core/security/secure_firestore.dart';
import 'package:laqta/features/review/data/datasources/review_remote_data_source.dart';
import 'package:laqta/features/review/data/dtos/review_dto.dart';

class FirestoreReviewRemoteDataSource implements ReviewRemoteDataSource {
  final LegacyDataStore _firestore;
  final SecureFirestore _secure;

  FirestoreReviewRemoteDataSource({LegacyDataStore? firestore})
    : _firestore = firestore ?? LegacyDataStore.instance,
      _secure = SecureFirestore(firestore ?? LegacyDataStore.instance);

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('reviews');

  @override
  Future<void> submitReview(ReviewDto review) async {
    await _secure.guard(() => _collection.add(review.toMap()));
  }
}
