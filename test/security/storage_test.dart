import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laqta/core/auth/token_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'test_jwt.dart';

void main() {
  setUp(() {
    FlutterSecureStorage.setMockInitialValues(<String, String>{});
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('tokens are stored in secure storage, not SharedPreferences', () async {
    final tokenManager = TokenManager();
    final token = testJwt(
      expiresAt: DateTime.now().add(const Duration(minutes: 10)),
    );

    await tokenManager.saveTokens(
      accessToken: token,
      refreshToken: token,
      userId: 'u1',
    );

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('backendJwt'), isNull);
    expect(await tokenManager.getAccessToken(), token);
  });

  test('logout clears token reads', () async {
    final tokenManager = TokenManager();
    final token = testJwt(
      expiresAt: DateTime.now().add(const Duration(minutes: 10)),
    );

    await tokenManager.saveTokens(
      accessToken: token,
      refreshToken: token,
      userId: 'u1',
    );
    await tokenManager.clearAllTokens();

    expect(await tokenManager.getAccessToken(), isNull);
    expect(await tokenManager.getRefreshToken(), isNull);
  });
}
