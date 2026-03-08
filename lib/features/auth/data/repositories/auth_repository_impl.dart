import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:luqta/core/domain/failures/failure.dart';
import 'package:luqta/core/domain/result/result.dart';
import 'package:luqta/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:luqta/features/auth/domain/entities/auth_user.dart';
import 'package:luqta/features/auth/domain/repositories/auth_repository.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  const AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<AuthUser?>> getCurrentUser() async {
    try {
      final dto = _remoteDataSource.getCurrentUser();
      return Result.success(dto?.toDomain());
    } catch (e) {
      return Result.failure(_mapFailure(e));
    }
  }

  @override
  Future<Result<AuthUser>> signInWithGoogle() async {
    try {
      final dto = await _remoteDataSource.signInWithGoogle();
      return Result.success(dto.toDomain());
    } catch (e) {
      return Result.failure(_mapFailure(e));
    }
  }

  @override
  Future<Result<AuthUser>> signInWithApple() async {
    try {
      final dto = await _remoteDataSource.signInWithApple();
      return Result.success(dto.toDomain());
    } catch (e) {
      return Result.failure(_mapFailure(e));
    }
  }

  @override
  Future<Result<AuthUser>> signInWithPassword({
    required String email,
    required String password,
  }) async {
    try {
      final dto = await _remoteDataSource.signInWithPassword(
        email: email,
        password: password,
      );
      return Result.success(dto.toDomain());
    } catch (e) {
      return Result.failure(_mapFailure(e));
    }
  }

  @override
  Future<Result<AuthUser>> signUpWithPassword({
    required String email,
    required String password,
  }) async {
    try {
      final dto = await _remoteDataSource.signUpWithPassword(
        email: email,
        password: password,
      );
      return Result.success(dto.toDomain());
    } catch (e) {
      return Result.failure(_mapFailure(e));
    }
  }

  @override
  Future<Result<AuthUser>> signInWithPhoneCredential({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final dto = await _remoteDataSource.signInWithPhoneCredential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      return Result.success(dto.toDomain());
    } catch (e) {
      return Result.failure(_mapFailure(e));
    }
  }

  @override
  Future<Result<void>> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(AuthUser user) onVerificationCompleted,
    required void Function(Failure failure) onVerificationFailed,
    required void Function(String verificationId) onCodeAutoRetrievalTimeout,
  }) async {
    try {
      await _remoteDataSource.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        onVerificationCompleted: (dto) {
          onVerificationCompleted(dto.toDomain());
        },
        onVerificationFailed: (error) {
          onVerificationFailed(_mapFailure(error));
        },
        onCodeSent: onCodeSent,
        onCodeAutoRetrievalTimeout: onCodeAutoRetrievalTimeout,
      );
      return Result.success(null);
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
    if (error is GoogleSignInException) {
      final code = error.code == GoogleSignInExceptionCode.canceled
          ? 'canceled'
          : error.code.name;
      return Failure(
        message: error.description ?? error.toString(),
        code: code,
      );
    }
    if (error is SignInWithAppleAuthorizationException) {
      final code = error.code == AuthorizationErrorCode.canceled
          ? 'canceled'
          : error.code.name;
      return Failure(
        message: error.message,
        code: code,
      );
    }
    if (error is FirebaseAuthException) {
      return Failure(
        message: error.message ?? error.toString(),
        code: error.code,
      );
    }
    return Failure(message: error.toString());
  }
}
