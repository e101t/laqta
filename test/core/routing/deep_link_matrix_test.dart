import 'package:flutter_test/flutter_test.dart';
import 'package:laqta/app/router/routes.dart';
import 'package:laqta/core/routing/deep_link_handler.dart';

void main() {
  final handler = DeepLinkHandler.forTesting();

  final validCases = <String, String>{
    'https://laqta.app/explore': Routes.explore,
    'https://laqta.app/chat/room1': Routes.chat.replaceFirst(':id', 'room1'),
    'https://laqta.app/profile/sara': Routes.photographer.replaceFirst(
      ':id',
      'sara',
    ),
    'laqta://profile/sara': Routes.photographer.replaceFirst(':id', 'sara'),
    'laqta://chat/room2': Routes.chat.replaceFirst(':id', 'room2'),
    'https://laqta.app/post/p1': Routes.main,
  };

  for (final entry in validCases.entries) {
    test('resolves ${entry.key}', () {
      expect(handler.resolve(Uri.parse(entry.key)), entry.value);
    });
  }

  final invalidCases = <String>[
    'http://laqta.app/explore',
    'https://evil.example/explore',
    'https://laqta.app/chat/room?debug=true',
    'https://laqta.app/chat/%2e%2e/secret',
    'https://laqta.app/unknown/1',
    'laqta://profile',
  ];

  for (final url in invalidCases) {
    test('rejects $url', () {
      expect(handler.resolve(Uri.parse(url)), isNull);
    });
  }
}
