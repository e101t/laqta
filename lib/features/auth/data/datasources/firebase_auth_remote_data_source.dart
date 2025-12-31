import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:luqta/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:luqta/features/auth/data/dtos/auth_user_dto.dart';

class FirebaseAuthRemoteDataSource implements AuthRemoteDataSource {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  FirebaseAuthRemoteDataSource({FirebaseAuth? auth, GoogleSignIn? googleSignIn})
    : _auth = auth ?? FirebaseAuth.instance,
      _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

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
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        try {
          final userCredential = await _auth.signInWithCredential(credential);
          final user = userCredential.user;
          if (user == null) {
            throw StateError('Phone sign-in returned no user');
          }
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
  }

  @override
  Future<void> deleteCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('No authenticated user');
    }
    await user.delete();
  }
}
