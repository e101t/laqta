import 'package:luqta/core/domain/result/result.dart';
import '../entities/dispute.dart';
import '../repositories/disputes_repository.dart';

class CreateDispute {
  final DisputesRepository _repository;

  const CreateDispute(this._repository);

  Future<Result<void>> call(Dispute dispute) {
    return _repository.createDispute(dispute);
  }
}
