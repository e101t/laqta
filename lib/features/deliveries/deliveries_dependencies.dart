import 'package:laqta/features/deliveries/data/datasources/api_deliveries_remote_data_source.dart';
import 'package:laqta/features/deliveries/data/datasources/deliveries_remote_data_source.dart';
import 'package:laqta/features/deliveries/data/repositories/deliveries_repository_impl.dart';
import 'package:laqta/features/deliveries/domain/repositories/deliveries_repository.dart';
import 'package:laqta/features/deliveries/domain/usecases/get_delivery_by_booking.dart';
import 'package:laqta/features/deliveries/domain/usecases/upsert_delivery.dart';
import 'package:laqta/features/deliveries/domain/usecases/upload_delivery_file.dart';

class DeliveriesDependencies {
  static DeliveriesRemoteDataSource? _remoteDataSource;
  static DeliveriesRepository? _repository;

  static DeliveriesRemoteDataSource get _remote =>
      _remoteDataSource ??= _buildRemote();

  static DeliveriesRemoteDataSource _buildRemote() =>
      ApiDeliveriesRemoteDataSource();

  static DeliveriesRepository get _resolvedRepository =>
      _repository ??= DeliveriesRepositoryImpl(_remote);

  static GetDeliveryByBooking getDeliveryByBooking() =>
      GetDeliveryByBooking(_resolvedRepository);

  static UpsertDelivery upsertDelivery() => UpsertDelivery(_resolvedRepository);

  static UploadDeliveryFile uploadDeliveryFile() =>
      UploadDeliveryFile(_resolvedRepository);
}
