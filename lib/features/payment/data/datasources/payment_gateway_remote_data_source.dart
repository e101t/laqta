import 'package:laqta/core/utils/legacy_data_compat.dart';
import 'package:laqta/features/payment/data/dtos/payment_intent_dto.dart';

abstract class PaymentGatewayRemoteDataSource {
  Future<PaymentIntentDto> createPaymentIntent({
    required String bookingId,
    required double amount,
    required String currency,
  });
}

class BackendFunctionClientPaymentGatewayRemoteDataSource
    implements PaymentGatewayRemoteDataSource {
  final BackendFunctionClient _functions;

  BackendFunctionClientPaymentGatewayRemoteDataSource({
    BackendFunctionClient? functions,
  }) : _functions = functions ?? BackendFunctionClient.instance;

  @override
  Future<PaymentIntentDto> createPaymentIntent({
    required String bookingId,
    required double amount,
    required String currency,
  }) async {
    final callable = _functions.httpsCallable('createPaymentIntent');
    final result = await callable.call({
      'bookingId': bookingId,
      'amount': amount,
      'currency': currency,
    });

    final data = Map<String, dynamic>.from(result.data as Map);
    return PaymentIntentDto.fromMap(data);
  }
}
