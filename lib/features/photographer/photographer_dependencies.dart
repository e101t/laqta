import 'package:laqta/features/photographer/data/datasources/firestore_photographer_remote_data_source.dart';
import 'package:laqta/features/photographer/data/datasources/photographer_remote_data_source.dart';
import 'package:laqta/features/photographer/data/repositories/photographer_repository_impl.dart';
import 'package:laqta/features/photographer/domain/repositories/photographer_repository.dart';
import 'package:laqta/features/photographer/domain/usecases/check_favorite_status.dart';
import 'package:laqta/features/photographer/domain/usecases/get_photographer_profile.dart';
import 'package:laqta/features/photographer/domain/usecases/set_favorite_status.dart';

class PhotographerDependencies {
  static final PhotographerRemoteDataSource _remoteDataSource =
      FirestorePhotographerRemoteDataSource();
  static final PhotographerRepository _repository = PhotographerRepositoryImpl(
    _remoteDataSource,
  );

  static GetPhotographerProfile getPhotographerProfile() =>
      GetPhotographerProfile(_repository);

  static CheckFavoriteStatus checkFavoriteStatus() =>
      CheckFavoriteStatus(_repository);

  static SetFavoriteStatus setFavoriteStatus() =>
      SetFavoriteStatus(_repository);
}
