import 'package:laqta/core/services/backend_api_client.dart';
import 'package:laqta/features/booking/data/datasources/booking_remote_data_source.dart';
import 'package:laqta/features/booking/data/dtos/booking_dto.dart';

class ApiBookingRemoteDataSource implements BookingRemoteDataSource {
  ApiBookingRemoteDataSource({BackendApiClient? apiClient})
    : _apiClient = apiClient ?? BackendApiClient();

  final BackendApiClient _apiClient;

  @override
  Future<List<BookingDto>> getMyBookings(String userId) async {
    final response = await _apiClient.get('/bookings/my');
    return _readList(response, 'bookings')
        .map((json) => BookingDto.fromJson(json))
        .toList();
  }

  @override
  Future<BookingDto> getBookingById(String bookingId) async {
    final response = await _apiClient.get('/bookings/$bookingId');
    final map = _readMap(response, 'booking');
    return BookingDto.fromJson(map);
  }

  @override
  Future<void> createBooking(BookingDto booking) async {
    await _apiClient.post('/bookings', body: booking.toJson());
  }

  @override
  Future<void> updateBookingStatus(String bookingId, String status) async {
    await _apiClient.patch(
      '/bookings/$bookingId/status',
      body: {'status': status},
    );
  }

  @override
  Future<void> updateBooking(
    String bookingId,
    Map<String, dynamic> updates,
  ) async {
    await _apiClient.patch('/bookings/$bookingId', body: updates);
  }

  @override
  String generateBookingId() =>
      'booking_${DateTime.now().millisecondsSinceEpoch}';

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
      final value = response[key];
      if (value is Map) return Map<String, dynamic>.from(value);
      if (response.containsKey('id')) return response;
    }
    throw const BackendApiException('Unexpected backend response format.');
  }
}
