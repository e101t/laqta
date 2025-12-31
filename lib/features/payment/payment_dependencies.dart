import 'package:luqta/features/payment/data/datasources/firestore_payment_remote_data_source.dart';
import 'package:luqta/features/payment/data/datasources/payment_remote_data_source.dart';
import 'package:luqta/features/payment/data/repositories/payment_repository_impl.dart';
import 'package:luqta/features/payment/domain/repositories/payment_repository.dart';
import 'package:luqta/features/payment/domain/usecases/update_booking_payment_status.dart';

class PaymentDependencies {
  static final PaymentRemoteDataSource _remoteDataSource =
      FirestorePaymentRemoteDataSource();
  static final PaymentRepository _repository = PaymentRepositoryImpl(
    _remoteDataSource,
  );

  static UpdateBookingPaymentStatus updateBookingPaymentStatus() =>
      UpdateBookingPaymentStatus(_repository);
}
