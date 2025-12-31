import 'package:luqta/core/domain/result/result.dart';

abstract class PaymentRepository {
  Future<Result<void>> updateBookingPaymentStatus({
    required String bookingId,
    required String paymentIntentId,
    required double amount,
  });
}
