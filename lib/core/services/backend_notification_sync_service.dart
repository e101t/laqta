import 'dart:async';
import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:laqta/core/services/backend_api_client.dart';
import 'package:laqta/core/services/backend_session_service.dart';

class BackendNotificationSyncService {
  BackendNotificationSyncService._();

  static final BackendNotificationSyncService instance =
      BackendNotificationSyncService._();

  final BackendSessionService _sessionService = BackendSessionService();
  final BackendApiClient _apiClient = BackendApiClient();

  StreamSubscription<String>? _tokenRefreshSubscription;
  bool _initialized = false;

  bool get _isFirebaseReady => Firebase.apps.isNotEmpty;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    _initialized = true;
    if (!_isFirebaseReady) {
      return;
    }

    final messaging = FirebaseMessaging.instance;
    await messaging.setForegroundNotificationPresentationOptions(
      alert: false,
      badge: false,
      sound: false,
    );

    _tokenRefreshSubscription = messaging.onTokenRefresh.listen((_) {
      unawaited(syncCurrentDeviceToken());
    });

    await syncCurrentDeviceToken();
  }

  Future<void> requestPermissionAndSync() async {
    if (!_isFirebaseReady) return;

    final settings = await FirebaseMessaging.instance.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      await syncCurrentDeviceToken();
    }
  }

  Future<void> syncCurrentDeviceToken() async {
    if (!_isFirebaseReady) return;

    final backendToken = await _sessionService.getToken();
    if (backendToken == null || backendToken.isEmpty) {
      return;
    }

    final fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken == null || fcmToken.isEmpty) {
      return;
    }

    try {
      await _apiClient.post(
        '/users/fcm-token',
        body: {'token': fcmToken, 'platform': _platform},
      );
    } catch (_) {
      try {
        await _apiClient.post(
          '/notifications/devices',
          body: {'token': fcmToken, 'platform': _platform},
        );
      } catch (_) {
        // Best effort; background re-sync can retry later.
      }
    }
  }

  Future<void> deleteCurrentDeviceToken() async {
    final backendToken = await _sessionService.getToken();
    if (backendToken == null || backendToken.isEmpty) {
      return;
    }
    try {
      await _apiClient.delete('/users/fcm-token');
    } catch (_) {
      // Logout must not be blocked by notification cleanup.
    }
  }

  Future<void> dispose() async {
    await _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = null;
    _initialized = false;
  }

  String get _platform {
    if (Platform.isAndroid) {
      return 'android';
    }
    if (Platform.isIOS) {
      return 'ios';
    }
    return 'unknown';
  }
}
