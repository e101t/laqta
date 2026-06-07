import 'package:flutter_test/flutter_test.dart';
import 'package:laqta/app/router/routes.dart';
import 'package:laqta/core/services/notification_navigation_service.dart';

void main() {
  test('notification navigation routes chat category to chat room', () {
    final path = NotificationNavigationService.resolveNotificationPath(
      type: 'chat',
      data: const <String, dynamic>{'room_id': 'abc'},
    );

    expect(path, Routes.chat.replaceFirst(':id', 'abc'));
  });

  test('notification navigation routes system category to notifications', () {
    final path = NotificationNavigationService.resolveNotificationPath(
      type: 'system',
      data: const <String, dynamic>{},
    );

    expect(path, Routes.notifications);
  });
}
