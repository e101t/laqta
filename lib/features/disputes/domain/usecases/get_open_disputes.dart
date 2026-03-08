import 'package:luqta/core/domain/result/result.dart';
import '../entities/dispute.dart';
import '../repositories/disputes_repository.dart';

class GetOpenDisputes {
  final DisputesRepository _repository;

  const GetOpenDisputes(this._repository);

  Future<Result<List<Dispute>>> call() {
    return _repository.getOpenDisputes();
  }
}
