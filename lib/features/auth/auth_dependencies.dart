import 'package:flutter/foundation.dart';
import 'package:laqta/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:laqta/features/auth/data/datasources/backend_auth_remote_data_source.dart';
import 'package:laqta/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:laqta/features/auth/domain/repositories/auth_repository.dart';
import 'package:laqta/features/auth/domain/usecases/complete_registration.dart';
import 'package:laqta/features/auth/domain/usecases/delete_current_user.dart';
import 'package:laqta/features/auth/domain/usecases/forgot_password.dart';
import 'package:laqta/features/auth/domain/usecases/get_current_user.dart';
import 'package:laqta/features/auth/domain/usecases/sign_in_with_password.dart';
import 'package:laqta/features/auth/domain/usecases/sign_out.dart';
import 'package:laqta/features/auth/domain/usecases/reset_password.dart';
import 'package:laqta/features/auth/domain/usecases/start_registration.dart';

class AuthDependencies {
  static final AuthRemoteDataSource _remoteDataSource =
      BackendAuthRemoteDataSource();
  static AuthRepository? _repositoryOverride;

  @visibleForTesting
  static void setRepositoryOverride(AuthRepository? repository) {
    _repositoryOverride = repository;
  }

  static AuthRepository get _repository =>
      _repositoryOverride ?? AuthRepositoryImpl(_remoteDataSource);

  static GetCurrentUser getCurrentUser() => GetCurrentUser(_repository);

  static SignInWithPassword signInWithPassword() =>
      SignInWithPassword(_repository);

  static StartRegistration startRegistration() =>
      StartRegistration(_repository);

  static CompleteRegistration completeRegistration() =>
      CompleteRegistration(_repository);

  static ForgotPassword forgotPassword() => ForgotPassword(_repository);

  static ResetPassword resetPassword() => ResetPassword(_repository);

  static SignOut signOut() => SignOut(_repository);

  static DeleteCurrentUser deleteCurrentUser() =>
      DeleteCurrentUser(_repository);
}
