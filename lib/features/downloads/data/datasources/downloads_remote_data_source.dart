import 'package:laqta/features/downloads/domain/entities/download_link_entity.dart';

abstract class DownloadsRemoteDataSource {
  Future<DownloadLinkBatch?> getBatch(String bookingId);

  Future<List<DownloadLinkBatch>> getAllBatches();

  Future<void> upsertBatch(DownloadLinkBatch batch);

  Future<void> deleteBatch(String bookingId);

  Future<String> resolveFileUrl({
    required String bookingId,
    required String fileReference,
  });
}
