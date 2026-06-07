import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:laqta/core/config/feature_flags.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('remote config service loads and caches feature flags', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final service = RemoteConfigService(
      preferences: await SharedPreferences.getInstance(),
      client: MockClient((request) async {
        return http.Response(
          '{"chatEnabled":true,"reelsEnabled":false,"storiesEnabled":true,"paymentsEnabled":true,"liveStreamsEnabled":false,"echocastEnabled":false}',
          200,
        );
      }),
    );

    final flags = await service.load();

    expect(flags.chatEnabled, isTrue);
    expect(flags.reelsEnabled, isFalse);
    expect(FeatureFlags.current.reelsEnabled, isFalse);
  });
}
