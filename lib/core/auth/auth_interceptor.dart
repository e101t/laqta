import 'package:laqta/core/auth/token_manager.dart';

class AuthInterceptor {
  AuthInterceptor({TokenManager? tokenManager})
    : _tokenManager = tokenManager ?? TokenManager();

  final TokenManager _tokenManager;

  Future<Map<String, String>> authorizedHeaders({
    required Map<String, String> baseHeaders,
  }) async {
    final token = await _tokenManager.getAccessToken();
    if (token == null || token.isEmpty) {
      throw const MissingAccessTokenException();
    }
    return <String, String>{...baseHeaders, 'Authorization': 'Bearer $token'};
  }
}

class MissingAccessTokenException implements Exception {
  const MissingAccessTokenException();

  @override
  String toString() => 'Missing backend session.';
}
