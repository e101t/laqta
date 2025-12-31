import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luqta/features/loyalty/data/datasources/loyalty_remote_data_source.dart';
import 'package:luqta/features/loyalty/data/dtos/loyalty_points_dto.dart';

class FirestoreLoyaltyRemoteDataSource implements LoyaltyRemoteDataSource {
  final FirebaseFirestore _firestore;

  FirestoreLoyaltyRemoteDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('loyalty_points');

  @override
  Future<LoyaltyPointsDto?> getLoyaltyPoints(String userId) async {
    final doc = await _collection.doc(userId).get();
    if (!doc.exists) {
      return null;
    }
    return LoyaltyPointsDto.fromFirestore(doc);
  }

  @override
  Future<void> saveLoyaltyPoints(String userId, LoyaltyPointsDto points) async {
    await _collection.doc(userId).set(points.toMap());
  }
}
