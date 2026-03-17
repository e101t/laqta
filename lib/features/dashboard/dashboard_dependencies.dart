import 'package:laqta/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:laqta/features/dashboard/data/datasources/firestore_dashboard_remote_data_source.dart';
import 'package:laqta/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:laqta/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:laqta/features/dashboard/domain/usecases/get_photographer_bookings.dart';

class DashboardDependencies {
  static final DashboardRemoteDataSource _remoteDataSource =
      FirestoreDashboardRemoteDataSource();
  static final DashboardRepository _repository = DashboardRepositoryImpl(
    _remoteDataSource,
  );

  static GetPhotographerBookings getPhotographerBookings() =>
      GetPhotographerBookings(_repository);
}
