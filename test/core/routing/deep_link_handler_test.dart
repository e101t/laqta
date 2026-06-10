import 'package:flutter_test/flutter_test.dart';
import 'package:laqta/app/router/routes.dart';
import 'package:laqta/core/routing/deep_link_handler.dart';

void main() {
  test('deep link handler resolves chat links safely', () {
    final handler = DeepLinkHandler.forTesting();

    final path = handler.resolve(Uri.parse('https://laqta.app/chat/room123'));

    expect(path, Routes.chat.replaceFirst(':id', 'room123'));
  });

  test('deep link handler rejects path traversal and query params', () {
    final handler = DeepLinkHandler.forTesting();

    expect(
      handler.resolve(Uri.parse('https://laqta.app/chat/../secret')),
      isNull,
    );
    expect(
      handler.resolve(Uri.parse('https://laqta.app/chat/room?x=1')),
      isNull,
    );
  });

  test('deep link handler resolves custom scheme profile links', () {
    final handler = DeepLinkHandler.forTesting();

    final path = handler.resolve(Uri.parse('laqta://profile/ahmed'));

    expect(path, Routes.photographer.replaceFirst(':id', 'ahmed'));
  });
}
