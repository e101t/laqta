import 'package:laqta/core/domain/result/result.dart';
import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class ResetPassword {
  final AuthRepository _repository;

  const ResetPassword(this._repository);

  Future<Result<AuthUser>> call({
    required String requestId,
    required String code,
    required String newPassword,
    required String confirmPassword,
  }) {
    return _repository.resetPassword(
      requestId: requestId,
      code: code,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
  }
}
