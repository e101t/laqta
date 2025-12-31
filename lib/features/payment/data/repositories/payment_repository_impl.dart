import 'package:luqta/core/domain/failures/failure.dart';
import 'package:luqta/core/domain/result/result.dart';
import 'package:luqta/features/payment/data/datasources/payment_remote_data_source.dart';
import 'package:luqta/features/payment/domain/repositories/payment_repository.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteDataSource _remoteDataSource;

  const PaymentRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<void>> updateBookingPaymentStatus({
    required String bookingId,
    required String paymentIntentId,
    required double amount,
  }) async {
    try {
      await _remoteDataSource.updateBookingPaymentStatus(
        bookingId: bookingId,
        paymentIntentId: paymentIntentId,
        amount: amount,
      );
      return Result.success(null);
    } catch (_) {
      return Result.failure(
        const Failure(message: 'Failed to update payment status'),
      );
    }
  }
}
