import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:laqta/core/services/backend_notification_sync_service.dart';
import 'package:laqta/core/services/notification_navigation_service.dart';

class FcmService {
  FcmService._();

  static final FcmService instance = FcmService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final ValueNotifier<RemoteMessage?> foregroundMessage =
      ValueNotifier<RemoteMessage?>(null);

  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  bool _initialized = false;
  bool _permissionAskedThisSession = false;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    await _messaging.setForegroundNotificationPresentationOptions(
      alert: false,
      badge: false,
      sound: false,
    );

    _foregroundSubscription = FirebaseMessaging.onMessage.listen((message) {
      foregroundMessage.value = message;
    });

    await BackendNotificationSyncService.instance.initialize();
    await NotificationNavigationService.instance.initialize();
  }

  Future<void> requestPermissionAfterMeaningfulAction(
    BuildContext context,
  ) async {
    if (_permissionAskedThisSession) return;
    _permissionAskedThisSession = true;

    final settings = await _messaging.getNotificationSettings();
    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      await BackendNotificationSyncService.instance.syncCurrentDeviceToken();
      return;
    }
    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      return;
    }
    if (!context.mounted) return;

    final shouldRequest = await showDialog<bool>(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تفعيل الإشعارات'),
          content: const Text(
            'نريد إرسال إشعارات لك عند تلقي رسائل أو تفاعلات جديدة',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('لاحقاً'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('السماح'),
            ),
          ],
        ),
      ),
    );

    if (shouldRequest != true) return;
    await BackendNotificationSyncService.instance.requestPermissionAndSync();
  }

  Future<void> dispose() async {
    await _foregroundSubscription?.cancel();
    _foregroundSubscription = null;
    _initialized = false;
  }
}
