import 'package:laqta/core/domain/result/result.dart';
import 'package:laqta/features/profile/domain/entities/user_profile.dart';
import '../repositories/role_repository.dart';

class SaveUserRole {
  final RoleRepository _repository;

  const SaveUserRole(this._repository);

  Future<Result<UserProfile>> call({
    required String userId,
    required String role,
    required String lang,
    String? name,
    String? email,
    String? phone,
    String? photoUrl,
  }) {
    return _repository.saveUserRole(
      userId: userId,
      role: role,
      lang: lang,
      name: name,
      email: email,
      phone: phone,
      photoUrl: photoUrl,
    );
  }
}
