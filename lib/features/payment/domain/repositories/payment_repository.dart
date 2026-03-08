import 'package:luqta/core/domain/result/result.dart';
import 'package:luqta/features/payment/domain/entities/payment_intent.dart';

abstract class PaymentRepository {
  Future<Result<PaymentIntentData>> createPaymentIntent({
    required String bookingId,
    required double amount,
    required String currency,
  });

  Future<Result<void>> updateBookingPaymentStatus({
    required String bookingId,
    required String paymentIntentId,
    required double amount,
  });
}
