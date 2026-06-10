import 'package:laqta/core/domain/result/result.dart';
import '../repositories/profile_repository.dart';

class CheckUsernameAvailability {
  final ProfileRepository _repository;

  const CheckUsernameAvailability(this._repository);

  Future<Result<bool>> call(String usernameLower) {
    return _repository.isUsernameAvailable(usernameLower);
  }
}
