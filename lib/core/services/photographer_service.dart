import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luqta/core/models/photographer_model.dart';
import 'package:luqta/core/models/photographer_profile.dart';
import 'package:luqta/core/models/user_model.dart';

/// Encapsulates Firestore access for photographer listings.
class PhotographerService {
  PhotographerService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<List<PhotographerProfile>> fetchPhotographers({
    String? governorate,
    String? specialty,
    String? gender,
    double minRating = 0,
    int limit = 50,
  }) async {
    final snapshot = await _firestore
        .collection('photographers')
        .limit(limit)
        .get();

    if (snapshot.docs.isEmpty) return [];

    final photographers = snapshot.docs
        .map((doc) => PhotographerModel.fromFirestore(doc))
        .toList();

    final userMap = await _fetchUsers(photographers.map((p) => p.uid).toList());

    final profiles = <PhotographerProfile>[];
    for (final photographer in photographers) {
      final user = userMap[photographer.uid];
      if (user == null) {
        continue;
      }

      final profile = PhotographerProfile(
        photographer: photographer,
        user: user,
      );

      if (!profile.matchesMinRating(minRating)) continue;
      if (!profile.matchesGender(gender)) continue;
      if (!profile.matchesSpecialty(specialty)) continue;
      if (!profile.matchesGovernorate(governorate)) continue;

      profiles.add(profile);
    }

    profiles.sort((a, b) => b.rating.compareTo(a.rating));
    return profiles;
  }

  Future<PhotographerProfile?> fetchPhotographerProfile(
    String photographerId,
  ) async {
    final userRef = _firestore.collection('users').doc(photographerId);
    final photographerRef = _firestore
        .collection('photographers')
        .doc(photographerId);

    final results = await Future.wait([userRef.get(), photographerRef.get()]);
    final userDoc = results[0];
    final photographerDoc = results[1];

    if (!userDoc.exists || !photographerDoc.exists) {
      return null;
    }

    final user = UserModel.fromFirestore(userDoc);
    final photographer = PhotographerModel.fromFirestore(photographerDoc);

    return PhotographerProfile(photographer: photographer, user: user);
  }

  Future<Map<String, UserModel>> _fetchUsers(List<String> userIds) async {
    if (userIds.isEmpty) return {};

    final Map<String, UserModel> users = {};
    const chunkSize = 10;

    for (var i = 0; i < userIds.length; i += chunkSize) {
      final chunk = userIds.skip(i).take(chunkSize).toList();
      final snapshot = await _firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: chunk)
          .get();

      for (final doc in snapshot.docs) {
        final user = UserModel.fromFirestore(doc);
        users[user.uid] = user;
      }
    }

    return users;
  }
}
