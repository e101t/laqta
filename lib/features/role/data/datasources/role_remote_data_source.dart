import 'package:laqta/features/profile/data/dtos/user_profile_dto.dart';

abstract class RoleRemoteDataSource {
  Future<UserProfileDto> saveUserRole({
    required String userId,
    required String role,
    required String lang,
    String? name,
    String? email,
    String? phone,
    String? photoUrl,
  });
}
