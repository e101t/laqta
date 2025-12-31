import 'package:luqta/features/profile/data/datasources/firestore_profile_remote_data_source.dart';
import 'package:luqta/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:luqta/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:luqta/features/profile/domain/repositories/profile_repository.dart';
import 'package:luqta/features/profile/domain/usecases/check_username_availability.dart';
import 'package:luqta/features/profile/domain/usecases/delete_storage_file.dart';
import 'package:luqta/features/profile/domain/usecases/get_portfolio.dart';
import 'package:luqta/features/profile/domain/usecases/get_user_profile.dart';
import 'package:luqta/features/profile/domain/usecases/save_basic_info.dart';
import 'package:luqta/features/profile/domain/usecases/save_portfolio.dart';
import 'package:luqta/features/profile/domain/usecases/update_user_profile.dart';
import 'package:luqta/features/profile/domain/usecases/upload_portfolio_image.dart';
import 'package:luqta/features/profile/domain/usecases/upload_profile_photo.dart';

class ProfileDependencies {
  static final ProfileRemoteDataSource _remoteDataSource =
      FirestoreProfileRemoteDataSource();
  static final ProfileRepository _repository = ProfileRepositoryImpl(
    _remoteDataSource,
  );

  static GetUserProfile getUserProfile() => GetUserProfile(_repository);

  static UpdateUserProfile updateUserProfile() =>
      UpdateUserProfile(_repository);

  static SaveBasicInfo saveBasicInfo() => SaveBasicInfo(_repository);

  static CheckUsernameAvailability checkUsernameAvailability() =>
      CheckUsernameAvailability(_repository);

  static UploadProfilePhoto uploadProfilePhoto() =>
      UploadProfilePhoto(_repository);

  static GetPortfolio getPortfolio() => GetPortfolio(_repository);

  static SavePortfolio savePortfolio() => SavePortfolio(_repository);

  static UploadPortfolioImage uploadPortfolioImage() =>
      UploadPortfolioImage(_repository);

  static DeleteStorageFile deleteStorageFile() =>
      DeleteStorageFile(_repository);
}
