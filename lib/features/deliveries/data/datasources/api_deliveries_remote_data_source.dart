import 'package:laqta/core/services/backend_api_client.dart';
import 'package:laqta/features/deliveries/data/datasources/deliveries_remote_data_source.dart';
import 'package:laqta/features/deliveries/data/dtos/delivery_dto.dart';

class ApiDeliveriesRemoteDataSource implements DeliveriesRemoteDataSource {
  const ApiDeliveriesRemoteDataSource();

  BackendApiException _unsupported() => const BackendApiException(
    'Delivery APIs are not supported by the backend yet.',
  );

  @override
  Future<DeliveryDto?> getDeliveryByBooking(String bookingId) async {
    throw _unsupported();
  }

  @override
  Future<void> upsertDelivery(DeliveryDto delivery) async {
    throw _unsupported();
  }

  @override
  Future<String> uploadDeliveryFile({
    required String bookingId,
    required String deliveryId,
    required String filePath,
  }) async {
    throw _unsupported();
  }
}
