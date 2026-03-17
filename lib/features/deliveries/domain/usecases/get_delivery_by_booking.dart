import 'package:laqta/core/domain/result/result.dart';
import '../entities/delivery.dart';
import '../repositories/deliveries_repository.dart';

class GetDeliveryByBooking {
  final DeliveriesRepository _repository;

  const GetDeliveryByBooking(this._repository);

  Future<Result<Delivery?>> call(String bookingId) {
    return _repository.getDeliveryByBooking(bookingId);
  }
}
