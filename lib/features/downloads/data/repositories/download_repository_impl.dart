import 'package:luqta/features/downloads/data/datasources/downloads_remote_data_source.dart';
import 'package:luqta/features/downloads/domain/entities/download_link_entity.dart';
import 'package:luqta/features/downloads/domain/usecases/download_usecases.dart';

class DownloadRepositoryImpl implements DownloadRepository {
  final DownloadsRemoteDataSource _remoteDataSource;

  DownloadRepositoryImpl(this._remoteDataSource);

  @override
  Future<DownloadLinkBatch> generateDownloadLinks(
    String photographerId,
    String bookingId,
    String customerId,
    List<String> fileIds,
  ) async {
    final now = DateTime.now();
    final links = <DownloadLinkEntity>[];

    for (var i = 0; i < fileIds.length; i++) {
      final source = fileIds[i].trim();
      if (source.isEmpty) {
        continue;
      }
      final linkId = '${bookingId}__${now.millisecondsSinceEpoch}__$i';
      final temporaryUrl = await _resolveTemporaryUrl(
        bookingId: bookingId,
        source: source,
      );
      links.add(
        DownloadLinkEntity(
          linkId: linkId,
          bookingId: bookingId,
          photographerId: photographerId,
          customerId: customerId,
          fileUrl: source,
          temporaryUrl: temporaryUrl,
          createdAt: now,
          expiresAt: now.add(const Duration(days: 30)),
        ),
      );
    }

    final batch = DownloadLinkBatch(
      batchId: '${bookingId}_${now.millisecondsSinceEpoch}',
      bookingId: bookingId,
      links: links,
      photoCount: links.length,
      createdAt: now,
      includesRaw: false,
      includesEdited: true,
    );

    await _remoteDataSource.upsertBatch(batch);
    return batch;
  }

  @override
  Future<DownloadLinkEntity> extendLink(String linkId) async {
    final bookingId = _bookingIdFromLinkId(linkId);
    if (bookingId == null) {
      throw StateError('Invalid download link id');
    }

    final batch = await _remoteDataSource.getBatch(bookingId);
    if (batch == null) {
      throw StateError('Download batch not found');
    }

    final index = batch.links.indexWhere((link) => link.linkId == linkId);
    if (index == -1) {
      throw StateError('Download link not found');
    }

    final updatedLink = batch.links[index].extend();
    final updatedLinks = List<DownloadLinkEntity>.from(batch.links);
    updatedLinks[index] = updatedLink;

    await _remoteDataSource.upsertBatch(_copyBatch(batch, links: updatedLinks));
    return updatedLink;
  }

  @override
  Future<DownloadLinkBatch?> getDownloadLinks(String bookingId) async {
    final batch = await _remoteDataSource.getBatch(bookingId);
    if (batch == null) {
      return null;
    }

    var changed = false;
    final now = DateTime.now();
    final normalized = batch.links.map((link) {
      final expiredByTime = now.isAfter(link.expiresAt);
      if (expiredByTime && !link.isExpired) {
        changed = true;
        return link.copyWith(isExpired: true);
      }
      return link;
    }).toList();

    if (!changed) {
      return batch;
    }

    final updatedBatch = _copyBatch(batch, links: normalized);
    await _remoteDataSource.upsertBatch(updatedBatch);
    return updatedBatch;
  }

  @override
  Future<void> recordDownload(String linkId) async {
    final bookingId = _bookingIdFromLinkId(linkId);
    if (bookingId == null) {
      return;
    }

    final batch = await _remoteDataSource.getBatch(bookingId);
    if (batch == null) {
      return;
    }

    final index = batch.links.indexWhere((link) => link.linkId == linkId);
    if (index == -1) {
      return;
    }

    final updatedLinks = List<DownloadLinkEntity>.from(batch.links);
    updatedLinks[index] = updatedLinks[index].recordDownload();
    await _remoteDataSource.upsertBatch(_copyBatch(batch, links: updatedLinks));
  }

  @override
  Future<void> deleteExpiredLinks() async {
    final batches = await _remoteDataSource.getAllBatches();
    for (final batch in batches) {
      final remaining = batch.links.where((link) {
        final expired =
            link.isExpired || DateTime.now().isAfter(link.expiresAt);
        return !expired;
      }).toList();

      if (remaining.isEmpty) {
        await _remoteDataSource.deleteBatch(batch.bookingId);
        continue;
      }

      if (remaining.length != batch.links.length) {
        await _remoteDataSource.upsertBatch(
          _copyBatch(batch, links: remaining),
        );
      }
    }
  }

  Future<String> _resolveTemporaryUrl({
    required String bookingId,
    required String source,
  }) async {
    final uri = Uri.tryParse(source);
    if (uri != null && (uri.scheme == 'https' || uri.scheme == 'http')) {
      return source;
    }

    try {
      return await _remoteDataSource.resolveFileUrl(
        bookingId: bookingId,
        fileReference: source,
      );
    } catch (_) {
      return source;
    }
  }

  String? _bookingIdFromLinkId(String linkId) {
    final index = linkId.indexOf('__');
    if (index <= 0) {
      return null;
    }
    return linkId.substring(0, index);
  }

  DownloadLinkBatch _copyBatch(
    DownloadLinkBatch batch, {
    required List<DownloadLinkEntity> links,
  }) {
    return DownloadLinkBatch(
      batchId: batch.batchId,
      bookingId: batch.bookingId,
      links: links,
      photoCount: links.length,
      createdAt: batch.createdAt,
      includesRaw: batch.includesRaw,
      includesEdited: batch.includesEdited,
    );
  }
}
