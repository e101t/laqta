import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luqta/core/constants/app_constants.dart';
import 'package:luqta/features/favorites/data/datasources/favorites_remote_data_source.dart';
import 'package:luqta/features/favorites/data/dtos/favorite_dto.dart';
import 'package:luqta/features/photographer/data/dtos/photographer_dto.dart';
import 'package:luqta/features/profile/data/dtos/user_profile_dto.dart';

class FirestoreFavoritesRemoteDataSource implements FavoritesRemoteDataSource {
  final FirebaseFirestore _firestore;

  FirestoreFavoritesRemoteDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _favoritesCollection =>
      _firestore.collection('favorites');

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users_public');

  CollectionReference<Map<String, dynamic>> get _photographersCollection =>
      _firestore.collection('photographers');

  @override
  Future<List<FavoriteDto>> getFavorites(String userId) async {
    final snapshot = await _favoritesCollection
        .where('userId', isEqualTo: userId)
        .limit(AppConstants.queryLimit)
        .get();
    return snapshot.docs.map(FavoriteDto.fromFirestore).toList();
  }

  @override
  Future<List<UserProfileDto>> getUserProfiles(List<String> userIds) async {
    return _getByIds(userIds, _usersCollection, UserProfileDto.fromFirestore);
  }

  @override
  Future<List<PhotographerDetailsDto>> getPhotographerDetails(
    List<String> photographerIds,
  ) async {
    return _getByIds(
      photographerIds,
      _photographersCollection,
      PhotographerDetailsDto.fromFirestore,
    );
  }

  @override
  Future<void> removeFavorite(String userId, String photographerId) async {
    await _favoritesCollection.doc('${userId}_$photographerId').delete();
  }

  Future<List<T>> _getByIds<T>(
    List<String> ids,
    CollectionReference<Map<String, dynamic>> collection,
    T Function(DocumentSnapshot<Map<String, dynamic>>) mapper,
  ) async {
    if (ids.isEmpty) return <T>[];
    const chunkSize = 10;
    final results = <T>[];

    for (var i = 0; i < ids.length; i += chunkSize) {
      final chunk = ids.skip(i).take(chunkSize).toList();
      final snapshot = await collection
          .where(FieldPath.documentId, whereIn: chunk)
          .get();
      results.addAll(snapshot.docs.map(mapper));
    }

    return results;
  }
}
