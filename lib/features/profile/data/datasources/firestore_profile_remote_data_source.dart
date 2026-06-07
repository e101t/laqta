import 'package:laqta/core/utils/legacy_data_compat.dart';
import 'package:laqta/core/constants/app_constants.dart';
import 'package:laqta/core/services/backend_media_service.dart';
import 'package:laqta/core/services/backend_user_profile_service.dart';
import 'package:laqta/core/security/secure_firestore.dart';
import 'package:laqta/core/security/secure_exceptions.dart';
import 'package:laqta/core/utils/user_public_fields.dart';
import 'package:laqta/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:laqta/features/profile/data/dtos/portfolio_dto.dart';
import 'package:laqta/features/profile/data/dtos/user_profile_dto.dart';

class FirestoreProfileRemoteDataSource implements ProfileRemoteDataSource {
  final LegacyDataStore _firestore;
  final BackendFunctionClient _functions;
  final SecureFirestore _secure;
  final BackendMediaService _backendMedia;
  final BackendUserProfileService _backendProfile;

  FirestoreProfileRemoteDataSource({
    LegacyDataStore? firestore,
    BackendFunctionClient? functions,
    BackendMediaService? backendMediaService,
    BackendUserProfileService? backendUserProfileService,
  }) : _firestore = firestore ?? LegacyDataStore.instance,
       _functions = functions ?? BackendFunctionClient.instance,
       _secure = SecureFirestore(firestore ?? LegacyDataStore.instance),
       _backendMedia = backendMediaService ?? BackendMediaService(),
       _backendProfile =
           backendUserProfileService ?? BackendUserProfileService();

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
    }
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
    try {
      await _secure.guard(
        () => _usersPublicCollection
            .doc(userId)
            .set(payload, SetOptions(merge: true)),
      );
    } on SecureException {
      // The public mirror is best-effort only during the migration period.
      // Profile reads must keep working even when client-side rules reject
      // recreating `users_public`.
    }
  }

  Future<void> _saveProfileViaCallable({
    required String userId,
    required Map<String, dynamic> profile,
    required bool createIfMissing,
  }) async {
    if (userId.trim().isEmpty) {
      throw StateError('Missing userId');
    }
    if (AppConstants.useFirebaseEmulators) {
      await _saveProfileDirectly(
        userId: userId,
        profile: profile,
        createIfMissing: createIfMissing,
      );
      return;
    }
    try {
      final callable = _functions.httpsCallable('saveUserProfile');
      await callable.call(<String, dynamic>{
        'userId': userId,
        'createIfMissing': createIfMissing,
        'profile': profile,
      });
      await _syncBackendProfile(profile);
    } on BackendFunctionException catch (e) {
      if (!_shouldFallbackToDirectSave(e)) {
        rethrow;
      }
      await _saveProfileDirectly(
        userId: userId,
        profile: profile,
        createIfMissing: createIfMissing,
      );
    }
  }

  bool _shouldFallbackToDirectSave(BackendFunctionException error) {
    final code = error.code.trim().toLowerCase();
    final message = (error.message ?? '').trim().toLowerCase();
    return code == 'not-found' ||
        code == 'unimplemented' ||
        message.contains('not found') ||
        message.contains('route not found') ||
        message.contains('function not found');
  }

  Future<void> _saveProfileDirectly({
    required String userId,
    required Map<String, dynamic> profile,
    required bool createIfMissing,
  }) async {
    final usersRef = _usersCollection.doc(userId);
    final usersPublicRef = _usersPublicCollection.doc(userId);

    final userDoc = await _secure.guard(() => usersRef.get());
    final existing = userDoc.data() ?? <String, dynamic>{};
    final serverTimestamp = FieldValue.serverTimestamp();

    final nextUserData = <String, dynamic>{
      'uid': userId,
      'name': profile['name'] ?? existing['name'] ?? '',
      'email': profile.containsKey('email')
          ? profile['email']
          : existing['email'],
      'phone': profile.containsKey('phone')
          ? profile['phone']
          : existing['phone'],
      'photoMediaId': profile.containsKey('photoMediaId')
          ? profile['photoMediaId']
          : existing['photoMediaId'],
      'photoUrl': profile.containsKey('photoUrl')
          ? profile['photoUrl']
          : existing['photoUrl'],
      'role': profile['role'] ?? existing['role'] ?? 'customer',
      'username': profile.containsKey('username')
          ? profile['username']
          : existing['username'],
      'usernameLower': profile.containsKey('usernameLower')
          ? profile['usernameLower']
          : existing['usernameLower'],
      'gender': profile.containsKey('gender')
          ? profile['gender']
          : existing['gender'],
      'birthYear': profile.containsKey('birthYear')
          ? profile['birthYear']
          : existing['birthYear'],
      'age': profile.containsKey('age') ? profile['age'] : existing['age'],
      'governorate':
          profile['governorate'] ?? existing['governorate'] ?? 'بغداد',
      'lang': existing['lang'] ?? 'ar',
      'profileCompleted': profile.containsKey('profileCompleted')
          ? profile['profileCompleted']
          : existing['profileCompleted'] ?? false,
      'over18Confirmed': profile.containsKey('over18Confirmed')
          ? profile['over18Confirmed']
          : existing['over18Confirmed'] ?? false,
      'blockedUsers': existing['blockedUsers'] is List
          ? existing['blockedUsers']
          : <dynamic>[],
      'interests': existing['interests'] is List
          ? existing['interests']
          : <dynamic>[],
      'fcmToken': existing['fcmToken'],
      'lastSeen': existing['lastSeen'],
      'createdAt': existing['createdAt'] ?? serverTimestamp,
      'updatedAt': serverTimestamp,
    };

    if (createIfMissing || userDoc.exists) {
      await _secure.guard(
        () => usersRef.set(nextUserData, SetOptions(merge: true)),
      );
      final publicData = buildUserPublicData(nextUserData);
      publicData['createdAt'] =
          existing['createdAt'] ?? nextUserData['createdAt'];
      publicData['updatedAt'] = serverTimestamp;
      try {
        await _secure.guard(
          () => usersPublicRef.set(publicData, SetOptions(merge: true)),
        );
      } on SecureException {
        // The public profile mirror is a derived view. If rules reject this
        // client-side fallback write, keep the authoritative private profile
        // save successful and let the mirror be backfilled later once the
        // callable path is available again.
      }
      await _syncBackendProfile(nextUserData);
      return;
    }

    throw const SecureException('Request failed', code: 'not-found');
  }

  Future<void> _syncBackendProfile(Map<String, dynamic> profile) async {
    await _backendProfile.syncProfile(profile);
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
