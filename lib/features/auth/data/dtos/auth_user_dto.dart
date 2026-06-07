import 'package:laqta/features/auth/domain/entities/auth_user.dart';

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

  factory AuthUserDto.fromBackendJson(Map<String, dynamic> json) {
    final id = json['id'];
    if (id is! String || id.isEmpty) {
      throw StateError('Backend auth response is missing user.id');
    }
    return AuthUserDto(
      id: id,
      email: json['email'] as String?,
      phoneNumber: json['phone'] as String?,
      displayName: json['name'] as String?,
      photoUrl: json['photoUrl'] as String?,
      isAnonymous: false,
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
