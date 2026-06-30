import 'package:laqta/core/services/backend_api_client.dart';
import 'package:laqta/features/downloads/data/datasources/downloads_remote_data_source.dart';
import 'package:laqta/features/downloads/domain/entities/download_link_entity.dart';

class ApiDownloadsRemoteDataSource implements DownloadsRemoteDataSource {
  ApiDownloadsRemoteDataSource({BackendApiClient? apiClient})
    : _apiClient = apiClient ?? BackendApiClient();

  final BackendApiClient _apiClient;

  @override
  Future<DownloadLinkBatch?> getBatch(String bookingId) async {
    try {
      final response = await _apiClient.get(
        '/download-links/${Uri.encodeComponent(bookingId)}',
      );
      if (response is! Map<String, dynamic>) return null;
      final batch = response['batch'] is Map<String, dynamic>
          ? response['batch'] as Map<String, dynamic>
          : response;
      return DownloadLinkBatch.fromJson(batch);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<DownloadLinkBatch>> getAllBatches() async {
    try {
      final response = await _apiClient.get('/download-links/my');
      if (response is! Map<String, dynamic>) return const [];
      final list = response['batches'];
      if (list is! List) return const [];
      return list
          .whereType<Map<Object?, Object?>>()
          .map(
            (item) => DownloadLinkBatch.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<void> upsertBatch(DownloadLinkBatch batch) async {
    await _apiClient.post(
      '/download-links/${Uri.encodeComponent(batch.bookingId)}',
      body: batch.toJson(),
    );
  }

  @override
  Future<void> deleteBatch(String bookingId) async {
    await _apiClient.delete(
      '/download-links/${Uri.encodeComponent(bookingId)}',
    );
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
