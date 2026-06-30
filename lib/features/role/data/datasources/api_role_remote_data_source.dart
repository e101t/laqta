import 'package:laqta/core/services/backend_api_client.dart';
import 'package:laqta/features/profile/data/dtos/user_profile_dto.dart';
import 'package:laqta/features/role/data/datasources/role_remote_data_source.dart';

class ApiRoleRemoteDataSource implements RoleRemoteDataSource {
  ApiRoleRemoteDataSource({BackendApiClient? apiClient})
    : _apiClient = apiClient ?? BackendApiClient();

  final BackendApiClient _apiClient;

  @override
  Future<UserProfileDto> saveUserRole({
    required String userId,
    required String role,
    required String lang,
    String? name,
    String? email,
    String? phone,
    String? photoUrl,
  }) async {
    final body = <String, dynamic>{
      'role': role,
      'lang': lang,
      if (name != null && name.isNotEmpty) 'name': name,
      if (email != null && email.isNotEmpty) 'email': email,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
      if (photoUrl != null && photoUrl.isNotEmpty) 'photoUrl': photoUrl,
    };
    final response = await _apiClient.patch('/users/me', body: body);
    final data = response is Map<String, dynamic> ? response : <String, dynamic>{};
    final userMap = data['user'] is Map<String, dynamic>
        ? data['user'] as Map<String, dynamic>
        : data;
    return UserProfileDto.fromMap(userId, userMap);
  }
}
