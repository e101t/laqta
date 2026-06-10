import 'package:laqta/core/domain/result/result.dart';
import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class SignInWithPassword {
  final AuthRepository _repository;

  const SignInWithPassword(this._repository);

  Future<Result<AuthUser>> call({
    required String identifier,
    required String password,
  }) {
    return _repository.signInWithPassword(
      identifier: identifier,
      password: password,
    );
  }
}
