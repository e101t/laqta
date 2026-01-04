import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luqta/core/utils/user_public_fields.dart';
import 'package:luqta/features/profile/data/dtos/user_profile_dto.dart';
import 'package:luqta/features/role/data/datasources/role_remote_data_source.dart';

class FirestoreRoleRemoteDataSource implements RoleRemoteDataSource {
  final FirebaseFirestore _firestore;

  FirestoreRoleRemoteDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> get _usersPublicCollection =>
      _firestore.collection('users_public');

  @override
  Future<UserProfileDto> saveUserRole({
    required String userId,
    required String role,
    required String lang,
    String? name,
    String? email,
    String? phone,
    String? photoUrl,
  }) async {
    final userDocRef = _usersCollection.doc(userId);
    var delay = const Duration(milliseconds: 400);
    const maxAttempts = 3;

    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        final existingDoc = await userDocRef.get();
        final timestamp = FieldValue.serverTimestamp();

        if (existingDoc.exists) {
          await userDocRef.update({'role': role, 'updatedAt': timestamp});
        } else {
          await userDocRef.set({
            'uid': userId,
            'name': name ?? '',
            'email': email,
            'phone': phone,
            'photoUrl': photoUrl,
            'role': role,
            'username': null,
            'usernameLower': null,
            'gender': null,
            'birthYear': null,
            'age': null,
            'governorate': '',
            'lang': lang,
            'profileCompleted': false,
            'over18Confirmed': false,
            'blockedUsers': <String>[],
            'interests': <String>[],
            'createdAt': timestamp,
            'updatedAt': timestamp,
          });
        }

        final savedDoc = await userDocRef.get();
        await _syncPublicProfile(userId, savedDoc.data());
        return UserProfileDto.fromFirestore(savedDoc);
      } on FirebaseException catch (e) {
        final shouldRetry =
            e.code == 'unavailable' && attempt < maxAttempts - 1;
        if (shouldRetry) {
          await Future.delayed(delay);
          delay *= 2;
          continue;
        }
        rethrow;
      }
    }

    throw FirebaseException(
      plugin: 'cloud_firestore',
      message: 'Unable to save role after multiple attempts',
    );
  }

  Future<void> _syncPublicProfile(
    String userId,
    Map<String, dynamic>? data,
  ) async {
    if (data == null) return;
    final payload = buildUserPublicData(data);
    if (payload.isEmpty) return;
    if (!payload.containsKey('createdAt')) {
      payload['createdAt'] = data['createdAt'] ?? FieldValue.serverTimestamp();
    }
    payload['updatedAt'] = FieldValue.serverTimestamp();
    await _usersPublicCollection
        .doc(userId)
        .set(payload, SetOptions(merge: true));
  }
}
