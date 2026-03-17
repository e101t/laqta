import 'package:laqta/features/deliveries/data/datasources/deliveries_remote_data_source.dart';
import 'package:laqta/features/deliveries/data/datasources/firestore_deliveries_remote_data_source.dart';
import 'package:laqta/features/deliveries/data/repositories/deliveries_repository_impl.dart';
import 'package:laqta/features/deliveries/domain/repositories/deliveries_repository.dart';
import 'package:laqta/features/deliveries/domain/usecases/get_delivery_by_booking.dart';
import 'package:laqta/features/deliveries/domain/usecases/upsert_delivery.dart';
import 'package:laqta/features/deliveries/domain/usecases/upload_delivery_file.dart';

class DeliveriesDependencies {
  static final DeliveriesRemoteDataSource _remoteDataSource =
      FirestoreDeliveriesRemoteDataSource();
  static final DeliveriesRepository _repository = DeliveriesRepositoryImpl(
    _remoteDataSource,
  );

  static GetDeliveryByBooking getDeliveryByBooking() =>
      GetDeliveryByBooking(_repository);

  static UpsertDelivery upsertDelivery() => UpsertDelivery(_repository);

  static UploadDeliveryFile uploadDeliveryFile() =>
      UploadDeliveryFile(_repository);
}
