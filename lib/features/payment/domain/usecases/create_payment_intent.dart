import 'package:luqta/core/domain/result/result.dart';
import 'package:luqta/features/payment/domain/entities/payment_intent.dart';
import 'package:luqta/features/payment/domain/repositories/payment_repository.dart';

class CreatePaymentIntent {
  final PaymentRepository _repository;

  const CreatePaymentIntent(this._repository);

  Future<Result<PaymentIntentData>> call({
    required String bookingId,
    required double amount,
    required String currency,
  }) {
    return _repository.createPaymentIntent(
      bookingId: bookingId,
      amount: amount,
      currency: currency,
    );
  }
}
