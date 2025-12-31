abstract class PaymentRemoteDataSource {
  Future<void> updateBookingPaymentStatus({
    required String bookingId,
    required String paymentIntentId,
    required double amount,
  });
}
