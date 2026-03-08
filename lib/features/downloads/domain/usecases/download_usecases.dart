import 'package:luqta/features/downloads/domain/entities/download_link_entity.dart';

/// Generate Download Links UseCase
class GenerateDownloadLinksUseCase {
  final DownloadRepository repository;

  GenerateDownloadLinksUseCase({required this.repository});

  Future<DownloadLinkBatch> call(
    String photographerId,
    String bookingId,
    String customerId,
    List<String> fileIds,
  ) async {
    return repository.generateDownloadLinks(
      photographerId,
      bookingId,
      customerId,
      fileIds,
    );
  }
}

/// Extend Download Link UseCase
class ExtendDownloadLinkUseCase {
  final DownloadRepository repository;

  ExtendDownloadLinkUseCase({required this.repository});

  Future<DownloadLinkEntity> call(String linkId) async {
    return repository.extendLink(linkId);
  }
}

/// Get Download Links UseCase
class GetDownloadLinksUseCase {
  final DownloadRepository repository;

  GetDownloadLinksUseCase({required this.repository});

  Future<DownloadLinkBatch?> call(String bookingId) async {
    return repository.getDownloadLinks(bookingId);
  }
}

/// Download Repository Interface
abstract class DownloadRepository {
  Future<DownloadLinkBatch> generateDownloadLinks(
    String photographerId,
    String bookingId,
    String customerId,
    List<String> fileIds,
  );
  Future<DownloadLinkEntity> extendLink(String linkId);
  Future<DownloadLinkBatch?> getDownloadLinks(String bookingId);
  Future<void> recordDownload(String linkId);
  Future<void> deleteExpiredLinks();
}
