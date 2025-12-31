import 'package:luqta/core/domain/result/result.dart';
import '../repositories/home_repository.dart';

class GetFollowingIds {
  final HomeRepository _repository;

  const GetFollowingIds(this._repository);

  Future<Result<Set<String>>> call({required String userId}) {
    return _repository.getFollowingIds(userId: userId);
  }
}
