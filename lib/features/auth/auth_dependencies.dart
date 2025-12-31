import 'package:luqta/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:luqta/features/auth/data/datasources/firebase_auth_remote_data_source.dart';
import 'package:luqta/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:luqta/features/auth/domain/repositories/auth_repository.dart';
import 'package:luqta/features/auth/domain/usecases/delete_current_user.dart';
import 'package:luqta/features/auth/domain/usecases/get_current_user.dart';
import 'package:luqta/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:luqta/features/auth/domain/usecases/sign_in_with_phone_credential.dart';
import 'package:luqta/features/auth/domain/usecases/sign_out.dart';
import 'package:luqta/features/auth/domain/usecases/verify_phone_number.dart';

class AuthDependencies {
  static final AuthRemoteDataSource _remoteDataSource =
      FirebaseAuthRemoteDataSource();
  static final AuthRepository _repository = AuthRepositoryImpl(
    _remoteDataSource,
  );

  static GetCurrentUser getCurrentUser() => GetCurrentUser(_repository);

  static SignInWithGoogle signInWithGoogle() => SignInWithGoogle(_repository);

  static SignInWithPhoneCredential signInWithPhoneCredential() =>
      SignInWithPhoneCredential(_repository);

  static VerifyPhoneNumber verifyPhoneNumber() =>
      VerifyPhoneNumber(_repository);

  static SignOut signOut() => SignOut(_repository);

  static DeleteCurrentUser deleteCurrentUser() =>
      DeleteCurrentUser(_repository);
}
