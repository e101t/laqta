import 'package:laqta/core/domain/result/result.dart';
import '../repositories/deliveries_repository.dart';

class UploadDeliveryFile {
  final DeliveriesRepository _repository;

  const UploadDeliveryFile(this._repository);

  Future<Result<String>> call({
    required String bookingId,
    required String deliveryId,
    required String filePath,
  }) {
    return _repository.uploadDeliveryFile(
      bookingId: bookingId,
      deliveryId: deliveryId,
      filePath: filePath,
    );
  }
}
