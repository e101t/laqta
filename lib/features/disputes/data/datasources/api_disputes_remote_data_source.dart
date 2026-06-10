import 'package:laqta/core/services/backend_api_client.dart';
import 'package:laqta/features/disputes/data/datasources/disputes_remote_data_source.dart';
import 'package:laqta/features/disputes/data/dtos/dispute_dto.dart';

class ApiDisputesRemoteDataSource implements DisputesRemoteDataSource {
  const ApiDisputesRemoteDataSource();

  BackendApiException _unsupported() => const BackendApiException(
    'Dispute APIs are not supported by the backend yet.',
  );

  @override
  Future<DisputeDto?> getDisputeByBooking(String bookingId) async {
    throw _unsupported();
  }

  @override
  Future<List<DisputeDto>> getDisputesForUser(String userId) async {
    throw _unsupported();
  }

  @override
  Future<List<DisputeDto>> getOpenDisputes() async {
    throw _unsupported();
  }

  @override
  Future<void> createDispute(DisputeDto dispute) async {
    throw _unsupported();
  }

  @override
  Future<void> updateDispute(DisputeDto dispute) async {
    throw _unsupported();
  }
}
