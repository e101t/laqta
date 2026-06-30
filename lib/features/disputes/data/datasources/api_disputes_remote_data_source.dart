import 'package:laqta/core/services/backend_api_client.dart';
import 'package:laqta/features/disputes/data/datasources/disputes_remote_data_source.dart';
import 'package:laqta/features/disputes/data/dtos/dispute_dto.dart';

class ApiDisputesRemoteDataSource implements DisputesRemoteDataSource {
  ApiDisputesRemoteDataSource({BackendApiClient? apiClient})
    : _apiClient = apiClient ?? BackendApiClient();

  final BackendApiClient _apiClient;

  @override
  Future<DisputeDto?> getDisputeByBooking(String bookingId) async {
    final response = await _apiClient.get(
      '/disputes?bookingId=${Uri.encodeComponent(bookingId)}',
    );
    final list = _readList(response, 'disputes');
    if (list.isEmpty) return null;
    return DisputeDto.fromJson(list.first);
  }

  @override
  Future<List<DisputeDto>> getDisputesForUser(String userId) async {
    final response = await _apiClient.get('/disputes/my');
    return _readList(response, 'disputes')
        .map((json) => DisputeDto.fromJson(json))
        .toList();
  }

  @override
  Future<List<DisputeDto>> getOpenDisputes() async {
    final response = await _apiClient.get('/disputes?status=open');
    return _readList(response, 'disputes')
        .map((json) => DisputeDto.fromJson(json))
        .toList();
  }

  @override
  Future<void> createDispute(DisputeDto dispute) async {
    await _apiClient.post('/disputes', body: dispute.toJson());
  }

  @override
  Future<void> updateDispute(DisputeDto dispute) async {
    await _apiClient.patch('/disputes/${dispute.id}', body: dispute.toJson());
  }

  List<Map<String, dynamic>> _readList(dynamic response, String key) {
    if (response is Map<String, dynamic>) {
      final value = response[key];
      if (value is List) {
        return value
            .whereType<Map<Object?, Object?>>()
            .map(Map<String, dynamic>.from)
            .toList();
      }
    }
    if (response is List) {
      return response
          .whereType<Map<Object?, Object?>>()
          .map(Map<String, dynamic>.from)
          .toList();
    }
    return const [];
  }
}
