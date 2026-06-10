import 'package:laqta/core/services/backend_api_client.dart';
import 'package:laqta/features/payment/data/datasources/payment_gateway_remote_data_source.dart';
import 'package:laqta/features/payment/data/datasources/payment_remote_data_source.dart';
import 'package:laqta/features/payment/data/dtos/payment_intent_dto.dart';

class StripeService
    implements PaymentGatewayRemoteDataSource, PaymentRemoteDataSource {
  StripeService({BackendApiClient? apiClient})
    : _apiClient = apiClient ?? BackendApiClient();

  final BackendApiClient _apiClient;

  @override
  Future<PaymentIntentDto> createPaymentIntent({
    required String bookingId,
    required double amount,
    required String currency,
  }) async {
    final response = await _apiClient.post(
      '/payments/payment-intents',
      body: {'bookingId': bookingId, 'amount': amount, 'currency': currency},
    );
    if (response is! Map<String, dynamic>) {
      throw const BackendApiException('Invalid payment intent response.');
    }
    final data = response['paymentIntent'] is Map
        ? Map<String, dynamic>.from(response['paymentIntent'] as Map)
        : response;
    return PaymentIntentDto.fromMap(data);
  }

  @override
  Future<void> updateBookingPaymentStatus({
    required String bookingId,
    required String paymentIntentId,
    required double amount,
  }) async {
    await _apiClient.post(
      '/payments/payment-intents/confirm',
      body: {
        'bookingId': bookingId,
        'paymentIntentId': paymentIntentId,
        'amount': amount,
      },
    );
  }
}
