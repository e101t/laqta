import 'package:laqta/core/domain/result/result.dart';
import '../repositories/settings_repository.dart';

class DeleteUserData {
  final SettingsRepository _repository;

  const DeleteUserData(this._repository);

  Future<Result<void>> call({required String userId}) {
    return _repository.deleteUserData(userId: userId);
  }
}
