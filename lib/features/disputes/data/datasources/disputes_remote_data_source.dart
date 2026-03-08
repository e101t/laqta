import '../dtos/dispute_dto.dart';

abstract class DisputesRemoteDataSource {
  Future<DisputeDto?> getDisputeByBooking(String bookingId);

  Future<List<DisputeDto>> getDisputesForUser(String userId);

  Future<List<DisputeDto>> getOpenDisputes();

  Future<void> createDispute(DisputeDto dispute);

  Future<void> updateDispute(DisputeDto dispute);
}
