import 'package:laqta/features/loyalty/data/datasources/firestore_loyalty_remote_data_source.dart';
import 'package:laqta/features/loyalty/data/datasources/loyalty_remote_data_source.dart';
import 'package:laqta/features/loyalty/data/repositories/loyalty_repository_impl.dart';
import 'package:laqta/features/loyalty/domain/repositories/loyalty_repository.dart';
import 'package:laqta/features/loyalty/domain/usecases/get_loyalty_points.dart';

class LoyaltyDependencies {
  static final LoyaltyRemoteDataSource _remoteDataSource =
      FirestoreLoyaltyRemoteDataSource();
  static final LoyaltyRepository _repository = LoyaltyRepositoryImpl(
    _remoteDataSource,
  );

  static GetLoyaltyPoints getLoyaltyPoints() => GetLoyaltyPoints(_repository);
}
