import 'package:flutter_test/flutter_test.dart';
import 'package:laqta/core/config/feature_flags.dart';

void main() {
  test('default flags keep core features enabled', () {
    final flags = FeatureFlags.defaultFlags();

    expect(flags.chatEnabled, isTrue);
    expect(flags.reelsEnabled, isTrue);
    expect(flags.storiesEnabled, isTrue);
    expect(flags.paymentsEnabled, isTrue);
  });

  final fields = <String>[
    'chatEnabled',
    'reelsEnabled',
    'storiesEnabled',
    'paymentsEnabled',
    'liveStreamsEnabled',
    'echocastEnabled',
  ];

  for (final field in fields) {
    test('feature flag JSON can disable $field', () {
      final json = <String, dynamic>{
        'chatEnabled': true,
        'reelsEnabled': true,
        'storiesEnabled': true,
        'paymentsEnabled': true,
        'liveStreamsEnabled': true,
        'echocastEnabled': true,
        field: false,
      };
      final flags = FeatureFlags.fromJson(json);
      expect(flags.toJson()[field], isFalse);
    });
  }
}
