import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laqta/core/network/signing/request_signer.dart';

void main() {
  setUp(() {
    FlutterSecureStorage.setMockInitialValues(<String, String>{});
  });

  test('request signer adds replay-protection headers', () async {
    final headers = await RequestSigner().buildHeaders(
      method: 'POST',
      uri: Uri.parse('https://api.laqta.cloud/api/v1/payments/payment-intents'),
      body: '{"amount":100}',
      accessToken: 'token-material',
      sensitive: true,
    );

    expect(headers['X-Request-ID'], isNotEmpty);
    expect(headers['X-Timestamp'], isNotEmpty);
    expect(headers['X-Body-SHA256'], isNotEmpty);
    expect(headers['X-Signature'], isNotEmpty);
    expect(headers['X-Device-ID'], isNotEmpty);
  });

  test('source tree contains no Stripe secret keys', () async {
    final offenders = <String>[];
    await for (final entity in Directory('lib').list(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final text = await entity.readAsString();
      final liveSecretPrefix = 'sk_${'live'}';
      final testSecretPrefix = 'sk_${'test'}';
      if (text.contains(liveSecretPrefix) || text.contains(testSecretPrefix)) {
        offenders.add(entity.path);
      }
    }

    expect(offenders, isEmpty);
  });
}
