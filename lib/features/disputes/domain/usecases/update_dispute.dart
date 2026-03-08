import 'package:luqta/core/domain/result/result.dart';
import '../entities/dispute.dart';
import '../repositories/disputes_repository.dart';

class UpdateDispute {
  final DisputesRepository _repository;

  const UpdateDispute(this._repository);

  Future<Result<void>> call(Dispute dispute) {
    return _repository.updateDispute(dispute);
  }
}
