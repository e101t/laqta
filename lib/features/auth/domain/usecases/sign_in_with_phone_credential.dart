import 'package:laqta/core/domain/result/result.dart';
import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class SignInWithPhoneCredential {
  final AuthRepository _repository;

  const SignInWithPhoneCredential(this._repository);

  Future<Result<AuthUser>> call({
    required String verificationId,
    required String smsCode,
  }) {
    return _repository.signInWithPhoneCredential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
  }
}
