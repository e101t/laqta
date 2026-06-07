import 'package:laqta/core/utils/legacy_data_compat.dart';
import 'package:laqta/core/security/secure_firestore.dart';
import 'package:laqta/features/downloads/data/datasources/downloads_remote_data_source.dart';
import 'package:laqta/features/downloads/domain/entities/download_link_entity.dart';

class FirestoreDownloadsRemoteDataSource implements DownloadsRemoteDataSource {
  final LegacyDataStore _firestore;
  final SecureFirestore _secure;

  FirestoreDownloadsRemoteDataSource({LegacyDataStore? firestore})
    : _firestore = firestore ?? LegacyDataStore.instance,
      _secure = SecureFirestore(firestore ?? LegacyDataStore.instance);

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
    final trimmed = fileReference.trim();
    if (trimmed.isEmpty) {
      throw StateError('Missing file reference for booking $bookingId');
    }

    return trimmed;
  }
}
