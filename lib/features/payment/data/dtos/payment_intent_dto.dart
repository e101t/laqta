import 'package:laqta/features/payment/domain/entities/payment_intent.dart';

class PaymentIntentDto {
  final String paymentIntentId;
  final String clientSecret;
  final String? customerId;
  final String? ephemeralKey;

  const PaymentIntentDto({
    required this.paymentIntentId,
    required this.clientSecret,
    this.customerId,
    this.ephemeralKey,
  });

  factory PaymentIntentDto.fromMap(Map<String, dynamic> data) {
    return PaymentIntentDto(
      paymentIntentId: data['paymentIntentId'] as String? ?? '',
      clientSecret: data['clientSecret'] as String? ?? '',
      customerId: data['customerId'] as String?,
      ephemeralKey: data['ephemeralKey'] as String?,
    );
  }

  PaymentIntentData toDomain() {
    return PaymentIntentData(
      paymentIntentId: paymentIntentId,
      clientSecret: clientSecret,
      customerId: customerId,
      ephemeralKey: ephemeralKey,
    );
  }
}
