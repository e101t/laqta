import 'package:laqta/features/auth/data/dtos/auth_user_dto.dart';

class AuthOtpStartDto {
  const AuthOtpStartDto({
    required this.requestId,
    required this.expiresInSeconds,
    required this.resendAfterSeconds,
    this.message,
  });

  final String requestId;
  final int expiresInSeconds;
  final int resendAfterSeconds;
  final String? message;
}

abstract class AuthRemoteDataSource {
  Future<AuthUserDto?> getCurrentUser();

  Future<AuthUserDto> signInWithPassword({
    required String identifier,
    required String password,
  });

  Future<AuthOtpStartDto> startRegistration({
    required String role,
    required String firstName,
    required String lastName,
    required String username,
    required String gender,
    required String birthdate,
    required String province,
    required String phone,
  });

  Future<AuthUserDto> completeRegistration({
    required String requestId,
    required String code,
    required String password,
    required String confirmPassword,
  });

  Future<AuthOtpStartDto> forgotPassword({required String phone});

  Future<AuthUserDto> resetPassword({
    required String requestId,
    required String code,
    required String newPassword,
    required String confirmPassword,
  });

  Future<void> signOut();

  Future<void> deleteCurrentUser();
}
