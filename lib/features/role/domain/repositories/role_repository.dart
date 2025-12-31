import 'package:luqta/core/domain/result/result.dart';
import 'package:luqta/features/profile/domain/entities/user_profile.dart';

abstract class RoleRepository {
  Future<Result<UserProfile>> saveUserRole({
    required String userId,
    required String role,
    required String lang,
    String? name,
    String? email,
    String? phone,
    String? photoUrl,
  });
}
