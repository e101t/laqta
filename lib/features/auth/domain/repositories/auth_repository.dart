import 'package:laqta/core/domain/result/result.dart';
import 'package:laqta/features/auth/data/datasources/auth_remote_data_source.dart';
import '../entities/auth_user.dart';

abstract class AuthRepository {
  Future<Result<AuthUser?>> getCurrentUser();

  Future<Result<AuthUser>> signInWithPassword({
    required String identifier,
    required String password,
  });

  Future<Result<AuthOtpStartDto>> startRegistration({
    required String role,
    required String firstName,
    required String lastName,
    required String username,
    required String gender,
    required String birthdate,
    required String province,
    required String phone,
  });

  Future<Result<AuthUser>> completeRegistration({
    required String requestId,
    required String code,
    required String password,
    required String confirmPassword,
  });

  Future<Result<AuthOtpStartDto>> forgotPassword({required String phone});

  Future<Result<AuthUser>> resetPassword({
    required String requestId,
    required String code,
    required String newPassword,
    required String confirmPassword,
  });

  Future<Result<void>> signOut();

  Future<Result<void>> deleteCurrentUser();
}
