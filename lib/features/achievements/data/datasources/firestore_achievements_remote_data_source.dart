import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luqta/core/constants/app_constants.dart';
import 'package:luqta/core/security/secure_firestore.dart';
import 'package:luqta/features/achievements/data/datasources/achievements_remote_data_source.dart';
import 'package:luqta/features/achievements/data/dtos/user_achievement_dto.dart';

class FirestoreAchievementsRemoteDataSource
    implements AchievementsRemoteDataSource {
  final FirebaseFirestore _firestore;
  final SecureFirestore _secure;

  FirestoreAchievementsRemoteDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _secure = SecureFirestore(firestore ?? FirebaseFirestore.instance);

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('user_achievements');

  @override
  Future<List<UserAchievementDto>> getUserAchievements(String userId) async {
    final snapshot = await _secure.guard(
      () => _collection
          .where('userId', isEqualTo: userId)
          .limit(AppConstants.queryLimit)
          .get(),
    );
    return snapshot.docs.map(UserAchievementDto.fromFirestore).toList();
  }
}
