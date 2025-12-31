import 'package:luqta/core/domain/result/result.dart';
import '../repositories/home_repository.dart';

class SetFollowStatus {
  final HomeRepository _repository;

  const SetFollowStatus(this._repository);

  Future<Result<void>> call({
    required String followerId,
    required String targetId,
    required bool follow,
  }) {
    return _repository.setFollowStatus(
      followerId: followerId,
      targetId: targetId,
      follow: follow,
    );
  }
}
