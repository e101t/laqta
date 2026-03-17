import 'package:laqta/features/analytics/data/datasources/analytics_remote_data_source.dart';
import 'package:laqta/features/analytics/data/datasources/firestore_analytics_remote_data_source.dart';
import 'package:laqta/features/analytics/data/repositories/analytics_repository_impl.dart';
import 'package:laqta/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:laqta/features/analytics/domain/usecases/get_photographer_analytics.dart';

class AnalyticsDependencies {
  static final AnalyticsRemoteDataSource _remoteDataSource =
      FirestoreAnalyticsRemoteDataSource();

  static final AnalyticsRepository _repository = AnalyticsRepositoryImpl(
    _remoteDataSource,
  );

  static GetPhotographerAnalytics getPhotographerAnalytics() =>
      GetPhotographerAnalytics(_repository);
}
