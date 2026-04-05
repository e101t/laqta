import 'package:laqta/core/services/backend_api_client.dart';
import 'package:laqta/features/booking/data/dtos/booking_dto.dart';
import 'package:laqta/features/requests/data/datasources/requests_remote_data_source.dart';
import 'package:laqta/features/requests/data/dtos/request_dto.dart';
import 'package:laqta/features/requests/data/dtos/request_offer_dto.dart';

class ApiRequestsRemoteDataSource implements RequestsRemoteDataSource {
  final BackendApiClient _apiClient;

  ApiRequestsRemoteDataSource({BackendApiClient? apiClient})
    : _apiClient = apiClient ?? BackendApiClient();

  @override
  Future<List<RequestDto>> getMyRequests(String clientId) async {
    final response = await _apiClient.get('/requests/my');
    final data = _readList(response, 'requests');
    return data.map((json) => RequestDto.fromJson(json)).toList();
  }

  @override
  Future<List<RequestDto>> getOpenRequests({String? governorate}) async {
    throw const BackendApiException(
      'Open requests are not supported by the backend yet.',
    );
  }

  @override
  Future<RequestDto> getRequestById(String requestId) async {
    final response = await _apiClient.get('/requests/$requestId');
    return RequestDto.fromJson(_readMap(response, 'request'));
  }

  @override
  Future<void> createRequest(RequestDto request) async {
    await _apiClient.post('/requests', body: request.toBackendCreateJson());
  }

  @override
  Future<void> updateRequest(
    String requestId,
    Map<String, dynamic> updates,
  ) async {
    throw const BackendApiException(
      'Request updates are not supported by the backend yet.',
    );
  }

  @override
  Future<List<RequestOfferDto>> getOffersForRequest(String requestId) async {
    throw const BackendApiException(
      'Request offers are not supported by the backend yet.',
    );
  }

  @override
  Future<List<RequestOfferDto>> getMyOffers(String photographerId) async {
    throw const BackendApiException(
      'Photographer offers are not supported by the backend yet.',
    );
  }

  @override
  Future<void> createOffer(RequestOfferDto offer) async {
    throw const BackendApiException(
      'Creating offers is not supported by the backend yet.',
    );
  }

  @override
  Future<void> acceptOffer({
    required RequestDto request,
    required RequestOfferDto offer,
    required BookingDto booking,
  }) async {
    throw const BackendApiException(
      'Accepting offers is not supported by the backend yet.',
    );
  }

  @override
  Future<String> uploadReferenceImage({
    required String requestId,
    required String filePath,
  }) async {
    throw const BackendApiException(
      'Reference image upload is not supported by the backend yet.',
    );
  }

  @override
  String generateRequestId() {
    // Generate a client-side ID or let the backend generate it
    return 'req_${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  String generateOfferId() {
    // Generate a client-side ID or let the backend generate it
    return 'offer_${DateTime.now().millisecondsSinceEpoch}';
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
    throw const BackendApiException('Unexpected backend response format.');
  }

  Map<String, dynamic> _readMap(dynamic response, String key) {
    if (response is Map<String, dynamic>) {
      final nested = response[key];
      if (nested is Map<String, dynamic>) {
        return nested;
      }
      if (nested is Map) {
        return Map<String, dynamic>.from(nested);
      }
    }
    throw const BackendApiException('Unexpected backend response format.');
  }
}
