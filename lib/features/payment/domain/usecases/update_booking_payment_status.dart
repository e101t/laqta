import 'package:laqta/core/domain/result/result.dart';
import '../repositories/payment_repository.dart';

class UpdateBookingPaymentStatus {
  final PaymentRepository _repository;

  const UpdateBookingPaymentStatus(this._repository);

  Future<Result<void>> call({
    required String bookingId,
    required String paymentIntentId,
    required double amount,
  }) {
    return _repository.updateBookingPaymentStatus(
      bookingId: bookingId,
      paymentIntentId: paymentIntentId,
      amount: amount,
    );
  }
}
