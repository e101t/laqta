import 'package:laqta/core/domain/result/result.dart';
import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class SignInWithApple {
  final AuthRepository _repository;

  const SignInWithApple(this._repository);

  Future<Result<AuthUser>> call() {
    return _repository.signInWithApple();
  }
}
