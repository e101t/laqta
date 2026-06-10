import 'package:laqta/core/domain/failures/failure.dart';
import 'package:laqta/core/domain/result/result.dart';
import 'package:laqta/core/security/secure_exceptions.dart';
import 'package:laqta/features/profile/data/mappers/profile_mapper.dart';
import 'package:laqta/features/profile/domain/entities/user_profile.dart';
import 'package:laqta/features/role/data/datasources/role_remote_data_source.dart';
import 'package:laqta/features/role/domain/repositories/role_repository.dart';

class RoleRepositoryImpl implements RoleRepository {
  final RoleRemoteDataSource _remoteDataSource;

  const RoleRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<UserProfile>> saveUserRole({
    required String userId,
    required String role,
    required String lang,
    String? name,
    String? email,
    String? phone,
    String? photoUrl,
  }) async {
    try {
      final dto = await _remoteDataSource.saveUserRole(
        userId: userId,
        role: role,
        lang: lang,
        name: name,
        email: email,
        phone: phone,
        photoUrl: photoUrl,
      );
      return Result.success(ProfileMapper.toDomain(dto));
    } catch (e) {
      String? code;
      if (e is SecureException) {
        code = e.code;
      }
      return Result.failure(
        Failure(message: 'Failed to save role', code: code ?? e.toString()),
      );
    }
  }
}
