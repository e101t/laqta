import '../dtos/delivery_dto.dart';

abstract class DeliveriesRemoteDataSource {
  Future<DeliveryDto?> getDeliveryByBooking(String bookingId);

  Future<void> upsertDelivery(DeliveryDto delivery);

  Future<String> uploadDeliveryFile({
    required String bookingId,
    required String deliveryId,
    required String filePath,
  });
}
