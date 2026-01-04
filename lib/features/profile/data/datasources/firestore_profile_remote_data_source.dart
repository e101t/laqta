import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:luqta/core/security/secure_firestore.dart';
import 'package:luqta/core/security/secure_storage.dart';
import 'package:luqta/core/utils/user_public_fields.dart';
import 'package:luqta/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:luqta/features/profile/data/dtos/portfolio_dto.dart';
import 'package:luqta/features/profile/data/dtos/user_profile_dto.dart';

class FirestoreProfileRemoteDataSource implements ProfileRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final SecureFirestore _secure;
  final SecureStorage _secureStorage;

  FirestoreProfileRemoteDataSource({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _storage = storage ?? FirebaseStorage.instance,
       _secure = SecureFirestore(firestore ?? FirebaseFirestore.instance),
       _secureStorage = SecureStorage(storage ?? FirebaseStorage.instance);

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> get _usersPublicCollection =>
      _firestore.collection('users_public');

  CollectionReference<Map<String, dynamic>> get _portfolioCollection =>
      _firestore.collection('portfolios');

  @override
  Future<UserProfileDto?> getUserProfile(String userId) async {
    final doc = await _secure.guard(() => _usersCollection.doc(userId).get());
    if (!doc.exists) {
      return null;
    }
    await _ensurePublicProfile(userId, doc.data());
    return UserProfileDto.fromFirestore(doc);
  }

  @override
  Future<void> updateUserProfile(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    await _secure.guard(() => _usersCollection.doc(userId).update(updates));
    await _syncPublicProfile(userId, updates);
  }

  @override
  Future<void> saveBasicInfo(String userId, Map<String, dynamic> data) async {
    await _secure.guard(
      () => _usersCollection.doc(userId).set({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)),
    );

    await _syncPublicProfile(userId, data);
  }

  @override
  Future<bool> isUsernameAvailable(String usernameLower) async {
    final snapshot = await _secure.guard(
      () => _usersCollection
          .where('usernameLower', isEqualTo: usernameLower)
          .limit(1)
          .get(),
    );
    return snapshot.docs.isEmpty;
  }

  @override
  Future<String> uploadProfilePhoto(String userId, String filePath) async {
    final storageRef = _storage
        .ref()
        .child('users')
        .child(userId)
        .child('profile')
        .child('profile_$userId.jpg');

    await _secureStorage.guard(
      () => storageRef.putFile(
        File(filePath),
        SettableMetadata(contentType: 'image/jpeg'),
      ),
    );
    return _secureStorage.guard(() => storageRef.getDownloadURL());
  }

  @override
  Future<PortfolioDto?> getPortfolio(String photographerId) async {
    final query = await _secure.guard(
      () => _portfolioCollection
          .where('photographerId', isEqualTo: photographerId)
          .limit(1)
          .get(),
    );

    if (query.docs.isEmpty) {
      return null;
    }
    return PortfolioDto.fromFirestore(query.docs.first);
  }

  @override
  Future<void> savePortfolio(
    String photographerId,
    List<PortfolioImageDto> images,
  ) async {
    final payload = {
      'photographerId': photographerId,
      'images': images.map((img) => img.toMap()).toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    final query = await _secure.guard(
      () => _portfolioCollection
          .where('photographerId', isEqualTo: photographerId)
          .limit(1)
          .get(),
    );

    if (query.docs.isNotEmpty) {
      await _secure.guard(() => query.docs.first.reference.update(payload));
    } else {
      await _secure.guard(() => _portfolioCollection.add(payload));
    }
  }

  @override
  Future<String> uploadPortfolioImage(
    String photographerId,
    String filePath,
  ) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final storageRef = _storage
        .ref()
        .child('photographers')
        .child(photographerId)
        .child('portfolio')
        .child(fileName);

    await _secureStorage.guard(
      () => storageRef.putFile(
        File(filePath),
        SettableMetadata(contentType: 'image/jpeg'),
      ),
    );
    return _secureStorage.guard(() => storageRef.getDownloadURL());
  }

  @override
  Future<void> deleteFileByUrl(String url) async {
    final ref = _storage.refFromURL(url);
    await _secureStorage.guard(() => ref.delete());
  }

  Future<void> _ensurePublicProfile(
    String userId,
    Map<String, dynamic>? data,
  ) async {
    if (data == null) return;
    final publicDoc = await _secure.guard(
      () => _usersPublicCollection.doc(userId).get(),
    );
    if (publicDoc.exists) return;

    final payload = buildUserPublicData(data);
    if (payload.isEmpty) return;
    if (!payload.containsKey('createdAt')) {
      payload['createdAt'] = data['createdAt'] ?? FieldValue.serverTimestamp();
    }
    payload['updatedAt'] = FieldValue.serverTimestamp();
    await _secure.guard(
      () => _usersPublicCollection
          .doc(userId)
          .set(payload, SetOptions(merge: true)),
    );
  }

  Future<void> _syncPublicProfile(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    final payload = buildUserPublicData(updates);
    if (payload.isEmpty) return;
    payload['updatedAt'] = FieldValue.serverTimestamp();
    await _secure.guard(
      () => _usersPublicCollection
          .doc(userId)
          .set(payload, SetOptions(merge: true)),
    );
  }
}
