import 'package:flutter/foundation.dart';
import 'package:laqta/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:laqta/features/auth/data/datasources/firebase_auth_remote_data_source.dart';
import 'package:laqta/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:laqta/features/auth/domain/repositories/auth_repository.dart';
import 'package:laqta/features/auth/domain/usecases/delete_current_user.dart';
import 'package:laqta/features/auth/domain/usecases/get_current_user.dart';
import 'package:laqta/features/auth/domain/usecases/sign_in_with_apple.dart';
import 'package:laqta/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:laqta/features/auth/domain/usecases/sign_in_with_password.dart';
import 'package:laqta/features/auth/domain/usecases/sign_in_with_phone_credential.dart';
import 'package:laqta/features/auth/domain/usecases/sign_out.dart';
import 'package:laqta/features/auth/domain/usecases/sign_up_with_password.dart';
import 'package:laqta/features/auth/domain/usecases/verify_phone_number.dart';

class AuthDependencies {
  static final AuthRemoteDataSource _remoteDataSource =
      FirebaseAuthRemoteDataSource();
  static AuthRepository? _repositoryOverride;

  @visibleForTesting
  static void setRepositoryOverride(AuthRepository? repository) {
    _repositoryOverride = repository;
  }

  static AuthRepository get _repository =>
      _repositoryOverride ?? AuthRepositoryImpl(_remoteDataSource);

  static GetCurrentUser getCurrentUser() => GetCurrentUser(_repository);

  static SignInWithGoogle signInWithGoogle() => SignInWithGoogle(_repository);

  static SignInWithApple signInWithApple() => SignInWithApple(_repository);

  static SignInWithPassword signInWithPassword() =>
      SignInWithPassword(_repository);

  static SignUpWithPassword signUpWithPassword() => SignUpWithPassword(
        _repository,
      );

  static SignInWithPhoneCredential signInWithPhoneCredential() =>
      SignInWithPhoneCredential(_repository);

  static VerifyPhoneNumber verifyPhoneNumber() =>
      VerifyPhoneNumber(_repository);

  static SignOut signOut() => SignOut(_repository);

  static DeleteCurrentUser deleteCurrentUser() =>
      DeleteCurrentUser(_repository);
}
