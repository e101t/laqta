import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:luqta/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:luqta/features/auth/data/dtos/auth_user_dto.dart';
import 'package:luqta/features/auth/data/services/backend_auth_exchange_service.dart';
import 'package:luqta/features/auth/data/utils/phone_number_utils.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class FirebaseAuthRemoteDataSource implements AuthRemoteDataSource {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final BackendAuthExchangeService _backendAuthExchangeService;

  FirebaseAuthRemoteDataSource({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
    BackendAuthExchangeService? backendAuthExchangeService,
  })
    : _auth = auth ?? FirebaseAuth.instance,
      _googleSignIn = googleSignIn ?? GoogleSignIn.instance,
      _backendAuthExchangeService =
          backendAuthExchangeService ?? BackendAuthExchangeService();

  @override
  AuthUserDto? getCurrentUser() {
    final user = _auth.currentUser;
    if (user == null) {
      return null;
    }
    return AuthUserDto.fromFirebaseUser(user);
  }

  @override
  Future<AuthUserDto> signInWithGoogle() async {
    await _googleSignIn.initialize();
    final googleUser = await _googleSignIn.authenticate();
    final googleAuth = googleUser.authentication;
    final idToken = googleAuth.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw StateError('Missing Google ID token');
    }

    final credential = GoogleAuthProvider.credential(idToken: idToken);
    final userCredential = await _auth.signInWithCredential(credential);
    final user = userCredential.user;
    if (user == null) {
      throw StateError('Google sign-in returned no user');
    }

    return AuthUserDto.fromFirebaseUser(user);
  }

  @override
  Future<AuthUserDto> signInWithApple() async {
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    final idToken = credential.identityToken;
    if (idToken == null || idToken.isEmpty) {
      throw StateError('Missing Apple identity token');
    }

    final oauthCredential = OAuthProvider(
      'apple.com',
    ).credential(idToken: idToken, accessToken: credential.authorizationCode);

    final userCredential = await _auth.signInWithCredential(oauthCredential);
    final user = userCredential.user;
    if (user == null) {
      throw StateError('Apple sign-in returned no user');
    }

    if ((user.displayName == null || user.displayName!.isEmpty) &&
        (credential.givenName != null || credential.familyName != null)) {
      final givenName = credential.givenName ?? '';
      final familyName = credential.familyName ?? '';
      final fullName = '$givenName $familyName'.trim();
      if (fullName.isNotEmpty) {
        await user.updateDisplayName(fullName);
      }
    }

    return AuthUserDto.fromFirebaseUser(user);
  }

  @override
  Future<AuthUserDto> signInWithPassword({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user;
    if (user == null) {
      throw StateError('Password sign-in returned no user');
    }
    return AuthUserDto.fromFirebaseUser(user);
  }

  @override
  Future<AuthUserDto> signUpWithPassword({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user;
    if (user == null) {
      throw StateError('Password sign-up returned no user');
    }
    return AuthUserDto.fromFirebaseUser(user);
  }

  @override
  Future<AuthUserDto> signInWithPhoneCredential({
    required String verificationId,
    required String smsCode,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    final userCredential = await _auth.signInWithCredential(credential);
    final user = userCredential.user;
    if (user == null) {
      throw StateError('Phone sign-in returned no user');
    }
    await _backendAuthExchangeService.exchangeCurrentFirebaseUser();
    return AuthUserDto.fromFirebaseUser(user);
  }

  @override
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required AuthPhoneVerificationCompleted onVerificationCompleted,
    required AuthPhoneVerificationFailed onVerificationFailed,
    required AuthPhoneCodeSent onCodeSent,
    required AuthPhoneCodeAutoRetrievalTimeout onCodeAutoRetrievalTimeout,
  }) async {
    final normalizedPhoneNumber = normalizePhoneNumberForFirebase(phoneNumber);
    await _auth.verifyPhoneNumber(
      phoneNumber: normalizedPhoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        try {
          final userCredential = await _auth.signInWithCredential(credential);
          final user = userCredential.user;
          if (user == null) {
            throw StateError('Phone sign-in returned no user');
          }
          await _backendAuthExchangeService.exchangeCurrentFirebaseUser();
          onVerificationCompleted(AuthUserDto.fromFirebaseUser(user));
        } catch (e) {
          onVerificationFailed(e);
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        onVerificationFailed(e);
      },
      codeSent: (String verificationId, int? resendToken) {
        onCodeSent(verificationId, resendToken);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        onCodeAutoRetrievalTimeout(verificationId);
      },
    );
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    await _backendAuthExchangeService.clearSession();
  }

  @override
  Future<void> deleteCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('No authenticated user');
    }
    await user.delete();
    await _backendAuthExchangeService.clearSession();
  }
}
