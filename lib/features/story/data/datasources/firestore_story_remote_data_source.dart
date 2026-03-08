import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:luqta/core/models/story_model.dart';
import 'package:luqta/core/security/secure_firestore.dart';
import 'package:luqta/core/security/secure_storage.dart';
import 'package:luqta/features/story/data/datasources/story_remote_data_source.dart';

class FirestoreStoryRemoteDataSource implements StoryRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final SecureFirestore _secure;
  final SecureStorage _secureStorage;

  FirestoreStoryRemoteDataSource({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _storage = storage ?? FirebaseStorage.instance,
       _secure = SecureFirestore(firestore ?? FirebaseFirestore.instance),
       _secureStorage = SecureStorage(storage ?? FirebaseStorage.instance);

  CollectionReference<Map<String, dynamic>> get _storiesCollection =>
      _firestore.collection('stories');

  @override
  Future<void> createStory(StoryModel story) async {
    await _secure.guard(
      () => _storiesCollection.doc(story.storyId).set(story.toFirestore()),
    );
  }

  @override
  Future<String> uploadStoryImage({
    required String photographerId,
    required String storyId,
    required String filePath,
    required String contentType,
  }) async {
    final extension = _extensionForContentType(contentType);
    final fileName =
        'story_${DateTime.now().millisecondsSinceEpoch}$extension';
    final storageRef = _storage
        .ref()
        .child('stories')
        .child(photographerId)
        .child(storyId)
        .child(fileName);

    await _secureStorage.guard(
      () => storageRef.putFile(
        File(filePath),
        SettableMetadata(contentType: contentType),
      ),
    );

    return _secureStorage.guard(() => storageRef.getDownloadURL());
  }

  String _extensionForContentType(String contentType) {
    if (contentType.contains('png')) return '.png';
    if (contentType.contains('jpeg') || contentType.contains('jpg')) {
      return '.jpg';
    }
    return '.jpg';
  }
}
