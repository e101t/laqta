import 'package:laqta/core/domain/result/result.dart';
import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class CompleteRegistration {
  final AuthRepository _repository;

  const CompleteRegistration(this._repository);

  Future<Result<AuthUser>> call({
    required String requestId,
    required String code,
    required String password,
    required String confirmPassword,
  }) {
    return _repository.completeRegistration(
      requestId: requestId,
      code: code,
      password: password,
      confirmPassword: confirmPassword,
    );
  }
}
