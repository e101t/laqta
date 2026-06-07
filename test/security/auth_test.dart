import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laqta/core/auth/device/device_binder.dart';
import 'package:laqta/core/auth/jwt/jwt_validator.dart';

import 'test_jwt.dart';

void main() {
  setUp(() {
    FlutterSecureStorage.setMockInitialValues(<String, String>{});
  });

  test('JWT none algorithm is rejected', () {
    final token = testJwt(
      alg: 'none',
      expiresAt: DateTime.now().add(const Duration(minutes: 5)),
    );
    final result = const JwtValidator(
      expectedIssuer: 'https://api.laqta.cloud',
      expectedAudience: 'laqta-app',
    ).validateAccessToken(token);

    expect(result.isValid, isFalse);
  });

  test('expired JWT is rejected', () {
    final token = testJwt(
      expiresAt: DateTime.now().subtract(const Duration(minutes: 1)),
    );
    final result = const JwtValidator(
      expectedIssuer: 'https://api.laqta.cloud',
      expectedAudience: 'laqta-app',
    ).validateAccessToken(token);

    expect(result.isValid, isFalse);
  });

  test('wrong issuer is rejected', () {
    final token = testJwt(
      iss: 'https://evil.example',
      expiresAt: DateTime.now().add(const Duration(minutes: 5)),
    );
    final result = const JwtValidator(
      expectedIssuer: 'https://api.laqta.cloud',
      expectedAudience: 'laqta-app',
    ).validateAccessToken(token);

    expect(result.isValid, isFalse);
  });

  test('device fingerprint remains stable within install', () async {
    final binder = DeviceBinder();
    final first = await binder.deviceId();
    final second = await binder.deviceId();

    expect(first, second);
    expect(first.length, 64);
  });
}
