import 'package:laqta/core/domain/failures/failure.dart';
import 'package:laqta/core/domain/result/result.dart';
import 'package:laqta/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:laqta/features/auth/domain/entities/auth_user.dart';
import 'package:laqta/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  const AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<AuthUser?>> getCurrentUser() async {
    try {
      final dto = await _remoteDataSource.getCurrentUser();
      return Result.success(dto?.toDomain());
    } catch (e) {
      return Result.failure(_mapFailure(e));
    }
  }

  @override
  Future<Result<AuthUser>> signInWithPassword({
    required String identifier,
    required String password,
  }) async {
    try {
      final dto = await _remoteDataSource.signInWithPassword(
        identifier: identifier,
        password: password,
      );
      return Result.success(dto.toDomain());
    } catch (e) {
      return Result.failure(_mapFailure(e));
    }
  }

  @override
  Future<Result<AuthOtpStartDto>> startRegistration({
    required String role,
    required String firstName,
    required String lastName,
    required String username,
    required String gender,
    required String birthdate,
    required String province,
    required String phone,
  }) async {
    try {
      final result = await _remoteDataSource.startRegistration(
        role: role,
        firstName: firstName,
        lastName: lastName,
        username: username,
        gender: gender,
        birthdate: birthdate,
        province: province,
        phone: phone,
      );
      return Result.success(result);
    } catch (e) {
      return Result.failure(_mapFailure(e));
    }
  }

  @override
  Future<Result<AuthUser>> completeRegistration({
    required String requestId,
    required String code,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final dto = await _remoteDataSource.completeRegistration(
        requestId: requestId,
        code: code,
        password: password,
        confirmPassword: confirmPassword,
      );
      return Result.success(dto.toDomain());
    } catch (e) {
      return Result.failure(_mapFailure(e));
    }
  }

  @override
  Future<Result<AuthOtpStartDto>> forgotPassword({
    required String phone,
  }) async {
    try {
      final result = await _remoteDataSource.forgotPassword(phone: phone);
      return Result.success(result);
    } catch (e) {
      return Result.failure(_mapFailure(e));
    }
  }

  @override
  Future<Result<AuthUser>> resetPassword({
    required String requestId,
    required String code,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final dto = await _remoteDataSource.resetPassword(
        requestId: requestId,
        code: code,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      return Result.success(dto.toDomain());
    } catch (e) {
      return Result.failure(_mapFailure(e));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _remoteDataSource.signOut();
      return Result.success(null);
    } catch (e) {
      return Result.failure(_mapFailure(e));
    }
  }

  @override
  Future<Result<void>> deleteCurrentUser() async {
    try {
      await _remoteDataSource.deleteCurrentUser();
      return Result.success(null);
    } catch (e) {
      return Result.failure(_mapFailure(e));
    }
  }

  Failure _mapFailure(Object error) {
    return Failure(message: error.toString());
  }
}
