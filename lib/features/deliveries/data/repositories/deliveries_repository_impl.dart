import 'package:laqta/core/domain/failures/failure.dart';
import 'package:laqta/core/domain/result/result.dart';
import 'package:laqta/features/deliveries/data/datasources/deliveries_remote_data_source.dart';
import 'package:laqta/features/deliveries/data/mappers/delivery_mapper.dart';
import 'package:laqta/features/deliveries/domain/entities/delivery.dart';
import 'package:laqta/features/deliveries/domain/repositories/deliveries_repository.dart';

class DeliveriesRepositoryImpl implements DeliveriesRepository {
  final DeliveriesRemoteDataSource _remoteDataSource;

  const DeliveriesRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<Delivery?>> getDeliveryByBooking(String bookingId) async {
    try {
      final dto = await _remoteDataSource.getDeliveryByBooking(bookingId);
      final delivery = dto == null ? null : DeliveryMapper.toDomain(dto);
      return Result.success(delivery);
    } catch (_) {
      return Result.failure(const Failure(message: 'Failed to load delivery'));
    }
  }

  @override
  Future<Result<void>> upsertDelivery(Delivery delivery) async {
    try {
      final dto = DeliveryMapper.toDto(delivery);
      await _remoteDataSource.upsertDelivery(dto);
      return Result.success(null);
    } catch (_) {
      return Result.failure(const Failure(message: 'Failed to save delivery'));
    }
  }

  @override
  Future<Result<String>> uploadDeliveryFile({
    required String bookingId,
    required String deliveryId,
    required String filePath,
  }) async {
    try {
      final url = await _remoteDataSource.uploadDeliveryFile(
        bookingId: bookingId,
        deliveryId: deliveryId,
        filePath: filePath,
      );
      return Result.success(url);
    } catch (_) {
      return Result.failure(const Failure(message: 'Failed to upload file'));
    }
  }
}
