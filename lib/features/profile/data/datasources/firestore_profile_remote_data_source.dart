import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:laqta/core/services/backend_media_service.dart';
import 'package:laqta/core/security/secure_firestore.dart';
import 'package:laqta/core/security/secure_storage.dart';
import 'package:laqta/core/utils/user_public_fields.dart';
import 'package:laqta/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:laqta/features/profile/data/dtos/portfolio_dto.dart';
import 'package:laqta/features/profile/data/dtos/user_profile_dto.dart';

class FirestoreProfileRemoteDataSource implements ProfileRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;
  final FirebaseStorage _storage;
  final SecureFirestore _secure;
  final SecureStorage _secureStorage;
  final BackendMediaService _backendMedia;

  FirestoreProfileRemoteDataSource({
    FirebaseFirestore? firestore,
    FirebaseFunctions? functions,
    FirebaseStorage? storage,
    BackendMediaService? backendMediaService,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _functions = functions ?? FirebaseFunctions.instance,
       _storage = storage ?? FirebaseStorage.instance,
       _secure = SecureFirestore(firestore ?? FirebaseFirestore.instance),
       _secureStorage = SecureStorage(storage ?? FirebaseStorage.instance),
       _backendMedia = backendMediaService ?? BackendMediaService();

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
    if (updates.isEmpty) return;
    await _saveProfileViaCallable(
      userId: userId,
      profile: updates,
      createIfMissing: false,
    );
  }

  @override
  Future<void> saveBasicInfo(String userId, Map<String, dynamic> data) async {
    await _saveProfileViaCallable(
      userId: userId,
      profile: data,
      createIfMissing: true,
    );
  }

  @override
  Future<bool> isUsernameAvailable(String usernameLower) async {
    final snapshot = await _secure.guard(
      () => _usersPublicCollection
          .where('usernameLower', isEqualTo: usernameLower)
          .limit(1)
          .get(),
    );
    return snapshot.docs.isEmpty;
  }

  @override
  Future<String> uploadProfilePhoto(String userId, String filePath) async {
    return _uploadImageToBackend(
      entityType: 'user',
      entityId: userId,
      filePath: filePath,
    );
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
    return _uploadImageToBackend(
      entityType: 'portfolio',
      entityId: photographerId,
      filePath: filePath,
    );
  }

  @override
  Future<void> deleteFileByUrl(String url) async {
    if (BackendMediaService.extractMediaId(url) != null) {
      await _backendMedia.deleteByUrl(url);
      return;
    }

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

  Future<void> _saveProfileViaCallable({
    required String userId,
    required Map<String, dynamic> profile,
    required bool createIfMissing,
  }) async {
    if (userId.trim().isEmpty) {
      throw StateError('Missing userId');
    }
    final callable = _functions.httpsCallable('saveUserProfile');
    await callable.call(<String, dynamic>{
      'userId': userId,
      'createIfMissing': createIfMissing,
      'profile': profile,
    });
  }

  Future<String> _uploadImageToBackend({
    required String entityType,
    required String entityId,
    required String filePath,
  }) async {
    return _backendMedia.uploadFile(
      entityType: entityType,
      entityId: entityId,
      filePath: filePath,
      publicContent: true,
    );
  }
}
