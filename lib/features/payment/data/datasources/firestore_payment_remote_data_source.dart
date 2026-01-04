import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luqta/core/security/secure_firestore.dart';
import 'package:luqta/features/payment/data/datasources/payment_remote_data_source.dart';

class FirestorePaymentRemoteDataSource implements PaymentRemoteDataSource {
  final FirebaseFirestore _firestore;
  final SecureFirestore _secure;

  FirestorePaymentRemoteDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _secure = SecureFirestore(firestore ?? FirebaseFirestore.instance);

  CollectionReference<Map<String, dynamic>> get _bookingsCollection =>
      _firestore.collection('bookings');

  @override
  Future<void> updateBookingPaymentStatus({
    required String bookingId,
    required String paymentIntentId,
    required double amount,
  }) async {
    await _secure.guard(
      () => _bookingsCollection.doc(bookingId).update({
        'payment.status': 'succeeded',
        'payment.intentId': paymentIntentId,
        'payment.paidAt': FieldValue.serverTimestamp(),
        'payment.amount': amount,
        'status': 'confirmed',
        'updatedAt': FieldValue.serverTimestamp(),
      }),
    );
  }
}
