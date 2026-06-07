import 'package:flutter_test/flutter_test.dart';
import 'package:laqta/core/network/cache/cache_policy.dart';

void main() {
  final cacheable = <String>[
    'https://api.laqta.cloud/api/v1/users/me',
    'https://api.laqta.cloud/api/v1/users/ahmed',
    'https://api.laqta.cloud/api/v1/timeline/home',
    'https://api.laqta.cloud/api/v1/timeline/explores',
    'https://api.laqta.cloud/api/v1/category',
    'https://api.laqta.cloud/api/v1/app/version',
    'https://api.laqta.cloud/api/v1/config/features',
  ];

  for (final url in cacheable) {
    test('cache policy exists for $url', () {
      expect(CachePolicy.forUri(Uri.parse(url)), isNotNull);
    });
  }

  final passThrough = <String>[
    'https://api.laqta.cloud/api/v1/payments',
    'https://api.laqta.cloud/api/v1/chat/messages',
    'https://api.laqta.cloud/api/v1/media/upload-url',
    'https://api.laqta.cloud/api/v1/auth/login',
  ];

  for (final url in passThrough) {
    test('cache policy ignores $url', () {
      expect(CachePolicy.forUri(Uri.parse(url)), isNull);
    });
  }
}
