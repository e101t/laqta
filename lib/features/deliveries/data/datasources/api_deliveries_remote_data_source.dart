import 'package:laqta/core/services/backend_api_client.dart';
import 'package:laqta/core/services/backend_media_service.dart';
import 'package:laqta/features/deliveries/data/datasources/deliveries_remote_data_source.dart';
import 'package:laqta/features/deliveries/data/dtos/delivery_dto.dart';

class ApiDeliveriesRemoteDataSource implements DeliveriesRemoteDataSource {
  ApiDeliveriesRemoteDataSource({
    BackendApiClient? apiClient,
    BackendMediaService? backendMediaService,
  }) : _apiClient = apiClient ?? BackendApiClient(),
       _backendMedia = backendMediaService ?? BackendMediaService();

  final BackendApiClient _apiClient;
  final BackendMediaService _backendMedia;

  @override
  Future<DeliveryDto?> getDeliveryByBooking(String bookingId) async {
    final encodedBookingId = Uri.encodeQueryComponent(bookingId);
    final response = await _apiClient.get(
      '/deliveries?bookingId=$encodedBookingId',
    );
    final payload = response as Map<String, dynamic>;
    final delivery = payload['delivery'];
    if (delivery is! Map<String, dynamic>) {
      return null;
    }
    return DeliveryDto.fromJson(delivery);
  }

  @override
  Future<void> upsertDelivery(DeliveryDto delivery) async {
    await _apiClient.post('/deliveries', body: delivery.toBackendJson());
  }

  @override
  Future<String> uploadDeliveryFile({
    required String bookingId,
    required String deliveryId,
    required String filePath,
  }) async {
    return _backendMedia.uploadFile(
      entityType: 'delivery',
      entityId: bookingId,
      filePath: filePath,
      publicContent: false,
    );
  }
}
