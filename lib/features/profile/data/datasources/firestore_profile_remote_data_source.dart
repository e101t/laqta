import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:luqta/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:luqta/features/profile/data/dtos/portfolio_dto.dart';
import 'package:luqta/features/profile/data/dtos/user_profile_dto.dart';

class FirestoreProfileRemoteDataSource implements ProfileRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  FirestoreProfileRemoteDataSource({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _storage = storage ?? FirebaseStorage.instance;

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> get _portfolioCollection =>
      _firestore.collection('portfolios');

  @override
  Future<UserProfileDto?> getUserProfile(String userId) async {
    final doc = await _usersCollection.doc(userId).get();
    if (!doc.exists) {
      return null;
    }
    return UserProfileDto.fromFirestore(doc);
  }

  @override
  Future<void> updateUserProfile(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    await _usersCollection.doc(userId).update(updates);
  }

  @override
  Future<void> saveBasicInfo(String userId, Map<String, dynamic> data) async {
    await _usersCollection.doc(userId).set({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<bool> isUsernameAvailable(String usernameLower) async {
    final snapshot = await _usersCollection
        .where('usernameLower', isEqualTo: usernameLower)
        .limit(1)
        .get();
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

    await storageRef.putFile(
      File(filePath),
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return storageRef.getDownloadURL();
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
  Future<void> savePortfolio(
    String photographerId,
    List<PortfolioImageDto> images,
  ) async {
    final payload = {
      'photographerId': photographerId,
      'images': images.map((img) => img.toMap()).toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    final query = await _portfolioCollection
        .where('photographerId', isEqualTo: photographerId)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      await query.docs.first.reference.update(payload);
    } else {
      await _portfolioCollection.add(payload);
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

    await storageRef.putFile(
      File(filePath),
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return storageRef.getDownloadURL();
  }

  @override
  Future<void> deleteFileByUrl(String url) async {
    final ref = _storage.refFromURL(url);
    await ref.delete();
  }
}
