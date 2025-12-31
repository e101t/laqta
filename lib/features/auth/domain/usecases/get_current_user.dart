import 'package:luqta/core/domain/result/result.dart';
import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class GetCurrentUser {
  final AuthRepository _repository;

  const GetCurrentUser(this._repository);

  Future<Result<AuthUser?>> call() {
    return _repository.getCurrentUser();
  }
}
