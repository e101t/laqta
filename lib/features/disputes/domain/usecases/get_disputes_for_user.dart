import 'package:luqta/core/domain/result/result.dart';
import '../entities/dispute.dart';
import '../repositories/disputes_repository.dart';

class GetDisputesForUser {
  final DisputesRepository _repository;

  const GetDisputesForUser(this._repository);

  Future<Result<List<Dispute>>> call(String userId) {
    return _repository.getDisputesForUser(userId);
  }
}
