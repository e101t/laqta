import 'package:luqta/core/domain/result/result.dart';
import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class SignInWithPassword {
  final AuthRepository _repository;

  const SignInWithPassword(this._repository);

  Future<Result<AuthUser>> call({
    required String email,
    required String password,
  }) {
    return _repository.signInWithPassword(email: email, password: password);
  }
}

