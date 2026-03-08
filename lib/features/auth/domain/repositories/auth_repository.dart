import 'package:luqta/core/domain/failures/failure.dart';
import 'package:luqta/core/domain/result/result.dart';
import '../entities/auth_user.dart';

abstract class AuthRepository {
  Future<Result<AuthUser?>> getCurrentUser();

  Future<Result<AuthUser>> signInWithGoogle();

  Future<Result<AuthUser>> signInWithApple();

  Future<Result<AuthUser>> signInWithPassword({
    required String email,
    required String password,
  });

  Future<Result<AuthUser>> signUpWithPassword({
    required String email,
    required String password,
  });

  Future<Result<AuthUser>> signInWithPhoneCredential({
    required String verificationId,
    required String smsCode,
  });

  Future<Result<void>> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(AuthUser user) onVerificationCompleted,
    required void Function(Failure failure) onVerificationFailed,
    required void Function(String verificationId) onCodeAutoRetrievalTimeout,
  });

  Future<Result<void>> signOut();

  Future<Result<void>> deleteCurrentUser();
}
