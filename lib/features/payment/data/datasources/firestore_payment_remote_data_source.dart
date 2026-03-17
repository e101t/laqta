import 'package:cloud_functions/cloud_functions.dart';
import 'package:laqta/features/payment/data/datasources/payment_remote_data_source.dart';

class FirestorePaymentRemoteDataSource implements PaymentRemoteDataSource {
  final FirebaseFunctions _functions;

  FirestorePaymentRemoteDataSource({FirebaseFunctions? functions})
    : _functions = functions ?? FirebaseFunctions.instance;

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
