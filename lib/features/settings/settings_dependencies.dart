import 'package:luqta/features/settings/data/datasources/firestore_settings_remote_data_source.dart';
import 'package:luqta/features/settings/data/datasources/settings_remote_data_source.dart';
import 'package:luqta/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:luqta/features/settings/domain/repositories/settings_repository.dart';
import 'package:luqta/features/settings/domain/usecases/delete_user_data.dart';
import 'package:luqta/features/settings/domain/usecases/submit_report.dart';

class SettingsDependencies {
  static final SettingsRemoteDataSource _remoteDataSource =
      FirestoreSettingsRemoteDataSource();
  static final SettingsRepository _repository = SettingsRepositoryImpl(
    _remoteDataSource,
  );

  static SubmitReport submitReport() => SubmitReport(_repository);

  static DeleteUserData deleteUserData() => DeleteUserData(_repository);
}
