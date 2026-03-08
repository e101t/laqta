class PaymentIntentData {
  final String paymentIntentId;
  final String clientSecret;
  final String? customerId;
  final String? ephemeralKey;

  const PaymentIntentData({
    required this.paymentIntentId,
    required this.clientSecret,
    this.customerId,
    this.ephemeralKey,
  });
}
