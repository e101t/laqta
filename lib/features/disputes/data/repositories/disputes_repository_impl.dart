import 'package:laqta/core/domain/failures/failure.dart';
import 'package:laqta/core/domain/result/result.dart';
import 'package:laqta/features/disputes/data/datasources/disputes_remote_data_source.dart';
import 'package:laqta/features/disputes/data/mappers/dispute_mapper.dart';
import 'package:laqta/features/disputes/domain/entities/dispute.dart';
import 'package:laqta/features/disputes/domain/repositories/disputes_repository.dart';

class DisputesRepositoryImpl implements DisputesRepository {
  final DisputesRemoteDataSource _remoteDataSource;

  const DisputesRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<Dispute?>> getDisputeByBooking(String bookingId) async {
    try {
      final dto = await _remoteDataSource.getDisputeByBooking(bookingId);
      final dispute = dto == null ? null : DisputeMapper.toDomain(dto);
      return Result.success(dispute);
    } catch (_) {
      return Result.failure(const Failure(message: 'Failed to load dispute'));
    }
  }

  @override
  Future<Result<List<Dispute>>> getDisputesForUser(String userId) async {
    try {
      final dtos = await _remoteDataSource.getDisputesForUser(userId);
      final disputes = dtos.map(DisputeMapper.toDomain).toList();
      return Result.success(disputes);
    } catch (_) {
      return Result.failure(const Failure(message: 'Failed to load disputes'));
    }
  }

  @override
  Future<Result<List<Dispute>>> getOpenDisputes() async {
    try {
      final dtos = await _remoteDataSource.getOpenDisputes();
      final disputes = dtos.map(DisputeMapper.toDomain).toList();
      return Result.success(disputes);
    } catch (_) {
      return Result.failure(
        const Failure(message: 'Failed to load open disputes'),
      );
    }
  }

  @override
  Future<Result<void>> createDispute(Dispute dispute) async {
    try {
      final dto = DisputeMapper.toDto(dispute);
      await _remoteDataSource.createDispute(dto);
      return Result.success(null);
    } catch (_) {
      return Result.failure(const Failure(message: 'Failed to create dispute'));
    }
  }

  @override
  Future<Result<void>> updateDispute(Dispute dispute) async {
    try {
      final dto = DisputeMapper.toDto(dispute);
      await _remoteDataSource.updateDispute(dto);
      return Result.success(null);
    } catch (_) {
      return Result.failure(const Failure(message: 'Failed to update dispute'));
    }
  }
}
