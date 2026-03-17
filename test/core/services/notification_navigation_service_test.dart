import 'package:flutter_test/flutter_test.dart';
import 'package:laqta/app/router/routes.dart';
import 'package:laqta/core/services/notification_navigation_service.dart';

void main() {
  group('NotificationNavigationService.resolveNotificationPath', () {
    test('uses explicit app route when present', () {
      final path = NotificationNavigationService.resolveNotificationPath(
        data: const {'route': '/notifications'},
      );

      expect(path, Routes.notifications);
    });

    test('resolves chat notifications with encoded name', () {
      final path = NotificationNavigationService.resolveNotificationPath(
        type: 'message',
        data: const {
          'chatId': 'chat-42',
          'otherUserName': 'Ali Hassan',
        },
      );

      expect(path, '/chat/chat-42?name=Ali%20Hassan');
    });

    test('resolves booking notifications using booking id', () {
      final path = NotificationNavigationService.resolveNotificationPath(
        type: 'booking',
        data: const {'bookingId': 'booking-77'},
      );

      expect(path, '/booking/booking-77');
    });

    test('falls back to request details when request id exists', () {
      final path = NotificationNavigationService.resolveNotificationPath(
        type: 'offer',
        data: const {'requestId': 'request-12'},
      );

      expect(path, '/requests/request-12');
    });

    test('falls back to notifications screen when no target exists', () {
      final path = NotificationNavigationService.resolveNotificationPath(
        type: 'system',
        data: const {'source': 'backend'},
      );

      expect(path, Routes.notifications);
    });
  });
}
