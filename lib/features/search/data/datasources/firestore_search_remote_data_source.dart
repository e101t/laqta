import 'package:laqta/core/utils/legacy_data_compat.dart';
import 'package:laqta/core/constants/app_constants.dart';
import 'package:laqta/core/security/secure_firestore.dart';
import 'package:laqta/features/photographer/data/dtos/photographer_dto.dart';
import 'package:laqta/features/profile/data/dtos/user_profile_dto.dart';
import 'package:laqta/features/search/data/datasources/search_remote_data_source.dart';

class FirestoreSearchRemoteDataSource implements SearchRemoteDataSource {
  final LegacyDataStore _firestore;
  final SecureFirestore _secure;

  FirestoreSearchRemoteDataSource({LegacyDataStore? firestore})
    : _firestore = firestore ?? LegacyDataStore.instance,
      _secure = SecureFirestore(firestore ?? LegacyDataStore.instance);

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users_public');

  CollectionReference<Map<String, dynamic>> get _photographersCollection =>
      _firestore.collection('photographers');

  @override
  Future<List<UserProfileDto>> getPhotographerUsers() async {
    final snapshot = await _secure.guard(
      () => _usersCollection
          .where('role', isEqualTo: 'photographer')
          .limit(AppConstants.queryLimit)
          .get(),
    );
    return snapshot.docs.map(UserProfileDto.fromFirestore).toList();
  }

  @override
  Future<List<PhotographerDetailsDto>> getPhotographerDetails() async {
    final snapshot = await _secure.guard(
      () => _photographersCollection.limit(AppConstants.queryLimit).get(),
    );
    return snapshot.docs.map(PhotographerDetailsDto.fromFirestore).toList();
  }
}
