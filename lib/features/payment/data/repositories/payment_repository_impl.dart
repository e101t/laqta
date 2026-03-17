import 'package:laqta/core/domain/failures/failure.dart';
import 'package:laqta/core/domain/result/result.dart';
import 'package:laqta/features/payment/data/datasources/payment_gateway_remote_data_source.dart';
import 'package:laqta/features/payment/data/datasources/payment_remote_data_source.dart';
import 'package:laqta/features/payment/domain/entities/payment_intent.dart';
import 'package:laqta/features/payment/domain/repositories/payment_repository.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteDataSource _remoteDataSource;
  final PaymentGatewayRemoteDataSource _gatewayDataSource;

  const PaymentRepositoryImpl(this._remoteDataSource, this._gatewayDataSource);

  @override
  Future<Result<PaymentIntentData>> createPaymentIntent({
    required String bookingId,
    required double amount,
    required String currency,
  }) async {
    try {
      final dto = await _gatewayDataSource.createPaymentIntent(
        bookingId: bookingId,
        amount: amount,
        currency: currency,
      );
      return Result.success(dto.toDomain());
    } catch (_) {
      return Result.failure(
        const Failure(message: 'Failed to create payment intent'),
      );
    }
  }

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
