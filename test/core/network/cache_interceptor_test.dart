import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:laqta/core/network/cache/cache_interceptor.dart';
import 'package:laqta/core/network/cache/response_cache.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('cache interceptor stores and returns fresh GET responses', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();
    final cache = ResponseCache(preferences: prefs);
    final interceptor = CacheInterceptor(cache: cache);
    final uri = Uri.parse('https://api.laqta.cloud/api/v1/app/version');

    await interceptor.write(
      'GET',
      uri,
      http.Response('{"latest_version_code":1}', 200),
    );
    final cached = await interceptor.readFresh('GET', uri);

    expect(cached, isNotNull);
    expect(cached!.body, contains('latest_version_code'));
  });

  test('cache interceptor ignores non-cacheable endpoints', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final interceptor = CacheInterceptor(
      cache: ResponseCache(preferences: await SharedPreferences.getInstance()),
    );
    final uri = Uri.parse('https://api.laqta.cloud/api/v1/payments');

    await interceptor.write('GET', uri, http.Response('{}', 200));

    expect(await interceptor.readFresh('GET', uri), isNull);
  });
}
