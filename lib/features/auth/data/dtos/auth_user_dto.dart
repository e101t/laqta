import 'package:firebase_auth/firebase_auth.dart';
import 'package:luqta/features/auth/domain/entities/auth_user.dart';

class AuthUserDto {
  final String id;
  final String? email;
  final String? phoneNumber;
  final String? displayName;
  final String? photoUrl;
  final bool isAnonymous;

  const AuthUserDto({
    required this.id,
    this.email,
    this.phoneNumber,
    this.displayName,
    this.photoUrl,
    required this.isAnonymous,
  });

  factory AuthUserDto.fromFirebaseUser(User user) {
    return AuthUserDto(
      id: user.uid,
      email: user.email,
      phoneNumber: user.phoneNumber,
      displayName: user.displayName,
      photoUrl: user.photoURL,
      isAnonymous: user.isAnonymous,
    );
  }

  AuthUser toDomain() {
    return AuthUser(
      id: id,
      email: email,
      phoneNumber: phoneNumber,
      displayName: displayName,
      photoUrl: photoUrl,
      isAnonymous: isAnonymous,
    );
  }
}
