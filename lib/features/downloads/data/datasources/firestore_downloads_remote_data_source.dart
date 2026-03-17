import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:laqta/core/security/secure_firestore.dart';
import 'package:laqta/core/security/secure_storage.dart';
import 'package:laqta/features/downloads/data/datasources/downloads_remote_data_source.dart';
import 'package:laqta/features/downloads/domain/entities/download_link_entity.dart';

class FirestoreDownloadsRemoteDataSource implements DownloadsRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final SecureFirestore _secure;
  final SecureStorage _secureStorage;

  FirestoreDownloadsRemoteDataSource({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _storage = storage ?? FirebaseStorage.instance,
       _secure = SecureFirestore(firestore ?? FirebaseFirestore.instance),
       _secureStorage = SecureStorage(storage ?? FirebaseStorage.instance);

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('download_links');

  @override
  Future<DownloadLinkBatch?> getBatch(String bookingId) async {
    final doc = await _secure.guard(() => _collection.doc(bookingId).get());
    if (!doc.exists || doc.data() == null) {
      return null;
    }
    return DownloadLinkBatch.fromJson(doc.data()!);
  }

  @override
  Future<List<DownloadLinkBatch>> getAllBatches() async {
    final snapshot = await _secure.guard(() => _collection.get());
    return snapshot.docs
        .where((doc) => doc.data().isNotEmpty)
        .map((doc) => DownloadLinkBatch.fromJson(doc.data()))
        .toList();
  }

  @override
  Future<void> upsertBatch(DownloadLinkBatch batch) async {
    await _secure.guard(
      () => _collection
          .doc(batch.bookingId)
          .set(batch.toJson(), SetOptions(merge: true)),
    );
  }

  @override
  Future<void> deleteBatch(String bookingId) async {
    await _secure.guard(() => _collection.doc(bookingId).delete());
  }

  @override
  Future<String> resolveFileUrl({
    required String bookingId,
    required String fileReference,
  }) async {
    final ref = _resolveStorageRef(
      bookingId: bookingId,
      fileReference: fileReference,
    );
    return _secureStorage.guard(() => ref.getDownloadURL());
  }

  Reference _resolveStorageRef({
    required String bookingId,
    required String fileReference,
  }) {
    final trimmed = fileReference.trim();
    final uri = Uri.tryParse(trimmed);

    if (uri != null &&
        uri.scheme == 'https' &&
        uri.host.contains('firebasestorage.googleapis.com')) {
      return _storage.refFromURL(trimmed);
    }

    if (trimmed.startsWith('gs://')) {
      return _storage.refFromURL(trimmed);
    }

    if (trimmed.contains('/')) {
      return _storage.ref().child(trimmed);
    }

    return _storage
        .ref()
        .child('deliveries')
        .child(bookingId)
        .child(bookingId)
        .child(trimmed);
  }
}
