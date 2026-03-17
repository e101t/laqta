import 'package:cloud_functions/cloud_functions.dart';
import 'package:laqta/features/payment/data/dtos/payment_intent_dto.dart';

abstract class PaymentGatewayRemoteDataSource {
  Future<PaymentIntentDto> createPaymentIntent({
    required String bookingId,
    required double amount,
    required String currency,
  });
}

class FirebaseFunctionsPaymentGatewayRemoteDataSource
    implements PaymentGatewayRemoteDataSource {
  final FirebaseFunctions _functions;

  FirebaseFunctionsPaymentGatewayRemoteDataSource({
    FirebaseFunctions? functions,
  }) : _functions = functions ?? FirebaseFunctions.instance;

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
