import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luqta/features/photographer/data/datasources/photographer_remote_data_source.dart';
import 'package:luqta/features/photographer/data/dtos/photographer_dto.dart';
import 'package:luqta/features/profile/data/dtos/portfolio_dto.dart';
import 'package:luqta/features/profile/data/dtos/user_profile_dto.dart';

class FirestorePhotographerRemoteDataSource
    implements PhotographerRemoteDataSource {
  final FirebaseFirestore _firestore;

  FirestorePhotographerRemoteDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users_public');

  CollectionReference<Map<String, dynamic>> get _photographersCollection =>
      _firestore.collection('photographers');

  CollectionReference<Map<String, dynamic>> get _portfolioCollection =>
      _firestore.collection('portfolios');

  CollectionReference<Map<String, dynamic>> get _reviewsCollection =>
      _firestore.collection('reviews');

  CollectionReference<Map<String, dynamic>> get _favoritesCollection =>
      _firestore.collection('favorites');

  @override
  Future<UserProfileDto?> getUserProfile(String userId) async {
    final doc = await _usersCollection.doc(userId).get();
    if (!doc.exists) {
      return null;
    }
    return UserProfileDto.fromFirestore(doc);
  }

  @override
  Future<PhotographerDetailsDto?> getPhotographerDetails(
    String photographerId,
  ) async {
    final doc = await _photographersCollection.doc(photographerId).get();
    if (!doc.exists) {
      return null;
    }
    return PhotographerDetailsDto.fromFirestore(doc);
  }

  @override
  Future<PortfolioDto?> getPortfolio(String photographerId) async {
    final query = await _portfolioCollection
        .where('photographerId', isEqualTo: photographerId)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      return null;
    }
    return PortfolioDto.fromFirestore(query.docs.first);
  }

  @override
  Future<List<PhotographerReviewDto>> getReviews(
    String photographerId, {
    int limit = 10,
  }) async {
    final query = await _reviewsCollection
        .where('targetId', isEqualTo: photographerId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    return query.docs.map(PhotographerReviewDto.fromFirestore).toList();
  }

  @override
  Future<bool> isFavorite(String userId, String photographerId) async {
    final doc = await _favoritesCollection
        .doc('${userId}_$photographerId')
        .get();
    return doc.exists;
  }

  @override
  Future<void> setFavorite(
    String userId,
    String photographerId,
    bool isFavorite,
  ) async {
    final docRef = _favoritesCollection.doc('${userId}_$photographerId');
    if (isFavorite) {
      await docRef.set({
        'userId': userId,
        'photographerId': photographerId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } else {
      await docRef.delete();
    }
  }
}
