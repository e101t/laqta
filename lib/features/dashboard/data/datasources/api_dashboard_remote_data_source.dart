import 'package:laqta/core/services/backend_api_client.dart';
import 'package:laqta/features/booking/data/dtos/booking_dto.dart';
import 'package:laqta/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:laqta/features/profile/data/dtos/user_profile_dto.dart';

class ApiDashboardRemoteDataSource implements DashboardRemoteDataSource {
  ApiDashboardRemoteDataSource({BackendApiClient? apiClient})
    : _apiClient = apiClient ?? BackendApiClient();

  final BackendApiClient _apiClient;

  @override
  Future<List<BookingDto>> getPhotographerBookings(
    String photographerId,
  ) async {
    final response = await _apiClient.get('/bookings/my');
    final raw = response is Map<String, dynamic> ? response : <String, dynamic>{};
    final list = raw['bookings'];
    if (list is! List) return const [];
    return list
        .whereType<Map<Object?, Object?>>()
        .map((item) => BookingDto.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  @override
  Future<List<UserProfileDto>> getUsersByIds(List<String> userIds) async {
    if (userIds.isEmpty) return const [];
    final ids = userIds.map(Uri.encodeComponent).join(',');
    final response = await _apiClient.get('/users/public?ids=$ids');
    final raw = response is Map<String, dynamic> ? response : <String, dynamic>{};
    final list = raw['users'];
    if (list is! List) return const [];
    return list
        .whereType<Map<Object?, Object?>>()
        .map((item) {
          final map = Map<String, dynamic>.from(item);
          final id = map['id'] as String? ?? map['uid'] as String? ?? '';
          return UserProfileDto.fromMap(id, map);
        })
        .toList();
  }
}
