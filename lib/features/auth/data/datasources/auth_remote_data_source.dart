import 'package:luqta/features/auth/data/dtos/auth_user_dto.dart';

typedef AuthPhoneCodeSent =
    void Function(String verificationId, int? resendToken);
typedef AuthPhoneVerificationCompleted = void Function(AuthUserDto user);
typedef AuthPhoneVerificationFailed = void Function(Object error);
typedef AuthPhoneCodeAutoRetrievalTimeout =
    void Function(String verificationId);

abstract class AuthRemoteDataSource {
  AuthUserDto? getCurrentUser();

  Future<AuthUserDto> signInWithGoogle();

  Future<AuthUserDto> signInWithPhoneCredential({
    required String verificationId,
    required String smsCode,
  });

  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required AuthPhoneVerificationCompleted onVerificationCompleted,
    required AuthPhoneVerificationFailed onVerificationFailed,
    required AuthPhoneCodeSent onCodeSent,
    required AuthPhoneCodeAutoRetrievalTimeout onCodeAutoRetrievalTimeout,
  });

  Future<void> signOut();

  Future<void> deleteCurrentUser();
}
