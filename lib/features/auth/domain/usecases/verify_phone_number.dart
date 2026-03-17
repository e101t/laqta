import 'package:laqta/core/domain/failures/failure.dart';
import 'package:laqta/core/domain/result/result.dart';
import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class VerifyPhoneNumber {
  final AuthRepository _repository;

  const VerifyPhoneNumber(this._repository);

  Future<Result<void>> call({
    required String phoneNumber,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(AuthUser user) onVerificationCompleted,
    required void Function(Failure failure) onVerificationFailed,
    required void Function(String verificationId) onCodeAutoRetrievalTimeout,
  }) {
    return _repository.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      onCodeSent: onCodeSent,
      onVerificationCompleted: onVerificationCompleted,
      onVerificationFailed: onVerificationFailed,
      onCodeAutoRetrievalTimeout: onCodeAutoRetrievalTimeout,
    );
  }
}
