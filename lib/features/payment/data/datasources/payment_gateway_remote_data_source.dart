import 'package:laqta/features/payment/data/dtos/payment_intent_dto.dart';

abstract class PaymentGatewayRemoteDataSource {
  Future<PaymentIntentDto> createPaymentIntent({
    required String bookingId,
    required double amount,
    required String currency,
  });
}

