import 'package:laqta/core/utils/legacy_data_compat.dart';
import 'package:laqta/features/payment/data/datasources/payment_remote_data_source.dart';

class FirestorePaymentRemoteDataSource implements PaymentRemoteDataSource {
  final BackendFunctionClient _functions;

  FirestorePaymentRemoteDataSource({BackendFunctionClient? functions})
    : _functions = functions ?? BackendFunctionClient.instance;

  @override
  Future<void> updateBookingPaymentStatus({
    required String bookingId,
    required String paymentIntentId,
    required double amount,
  }) async {
    final callable = _functions.httpsCallable('confirmPaymentIntent');
    await callable.call({
      'bookingId': bookingId,
      'paymentIntentId': paymentIntentId,
      'amount': amount,
    });
  }
}
