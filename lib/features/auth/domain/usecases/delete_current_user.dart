import 'package:luqta/core/domain/result/result.dart';
import '../repositories/auth_repository.dart';

class DeleteCurrentUser {
  final AuthRepository _repository;

  const DeleteCurrentUser(this._repository);

  Future<Result<void>> call() {
    return _repository.deleteCurrentUser();
  }
}
