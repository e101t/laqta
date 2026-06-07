import 'package:laqta/features/payment/data/datasources/payment_gateway_remote_data_source.dart';
import 'package:laqta/features/payment/data/datasources/payment_remote_data_source.dart';
import 'package:laqta/features/payment/data/repositories/payment_repository_impl.dart';
import 'package:laqta/features/payment/data/stripe_service.dart';
import 'package:laqta/features/payment/domain/repositories/payment_repository.dart';
import 'package:laqta/features/payment/domain/usecases/create_payment_intent.dart';
import 'package:laqta/features/payment/domain/usecases/update_booking_payment_status.dart';

class PaymentDependencies {
  static final StripeService _stripeService = StripeService();
  static final PaymentRemoteDataSource _remoteDataSource = _stripeService;
  static final PaymentGatewayRemoteDataSource _gatewayDataSource =
      _stripeService;
  static final PaymentRepository _repository = PaymentRepositoryImpl(
    _remoteDataSource,
    _gatewayDataSource,
  );

  static CreatePaymentIntent createPaymentIntent() =>
      CreatePaymentIntent(_repository);

  static UpdateBookingPaymentStatus updateBookingPaymentStatus() =>
      UpdateBookingPaymentStatus(_repository);
}
