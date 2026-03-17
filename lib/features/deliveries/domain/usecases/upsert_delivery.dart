import 'package:laqta/core/domain/result/result.dart';
import '../entities/delivery.dart';
import '../repositories/deliveries_repository.dart';

class UpsertDelivery {
  final DeliveriesRepository _repository;

  const UpsertDelivery(this._repository);

  Future<Result<void>> call(Delivery delivery) {
    return _repository.upsertDelivery(delivery);
  }
}
