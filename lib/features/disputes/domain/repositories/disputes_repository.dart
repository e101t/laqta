import 'package:laqta/core/domain/result/result.dart';
import '../entities/dispute.dart';

abstract class DisputesRepository {
  Future<Result<Dispute?>> getDisputeByBooking(String bookingId);

  Future<Result<List<Dispute>>> getDisputesForUser(String userId);

  Future<Result<List<Dispute>>> getOpenDisputes();

  Future<Result<void>> createDispute(Dispute dispute);

  Future<Result<void>> updateDispute(Dispute dispute);
}
