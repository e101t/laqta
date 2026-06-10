import 'package:laqta/core/domain/result/result.dart';
import '../entities/delivery.dart';

abstract class DeliveriesRepository {
  Future<Result<Delivery?>> getDeliveryByBooking(String bookingId);

  Future<Result<void>> upsertDelivery(Delivery delivery);

  Future<Result<String>> uploadDeliveryFile({
    required String bookingId,
    required String deliveryId,
    required String filePath,
  });
}
