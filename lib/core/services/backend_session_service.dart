import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:laqta/core/auth/token_manager.dart';

class BackendSessionService {
  BackendSessionService({
    FlutterSecureStorage? secureStorage,
    TokenManager? tokenManager,
  }) : _tokenManager =
           tokenManager ?? TokenManager(secureStorage: secureStorage);

  final TokenManager _tokenManager;

  Future<String?> getToken() => _tokenManager.getAccessToken();

  Future<String?> getRefreshToken() => _tokenManager.getRefreshToken();

  Future<String?> getUserId() => _tokenManager.getUserId();

  Future<bool> hasValidToken() => _tokenManager.hasValidAccessToken();

  Future<void> saveSession({
    required String token,
    String? refreshToken,
    String? userId,
    DateTime? accessTokenExpiresAt,
    DateTime? refreshTokenExpiresAt,
  }) {
    return _tokenManager.saveTokens(
      accessToken: token,
      refreshToken: refreshToken,
      userId: userId,
      accessTokenExpiresAt: accessTokenExpiresAt,
      refreshTokenExpiresAt: refreshTokenExpiresAt,
    );
  }

  Future<void> clear() => _tokenManager.clear();
}
