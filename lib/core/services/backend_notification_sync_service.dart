import 'dart:async';
import 'dart:io' show Platform;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:luqta/core/services/backend_api_client.dart';
import 'package:luqta/core/services/backend_session_service.dart';

class BackendNotificationSyncService {
  BackendNotificationSyncService._();

  static final BackendNotificationSyncService instance =
      BackendNotificationSyncService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final BackendSessionService _sessionService = const BackendSessionService();
  final BackendApiClient _apiClient = BackendApiClient();

  StreamSubscription<String>? _tokenRefreshSubscription;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    _initialized = true;
    await _messaging.requestPermission();
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    _tokenRefreshSubscription = _messaging.onTokenRefresh.listen((_) {
      unawaited(syncCurrentDeviceToken());
    });

    await syncCurrentDeviceToken();
  }

  Future<void> syncCurrentDeviceToken() async {
    final backendToken = await _sessionService.getToken();
    if (backendToken == null || backendToken.isEmpty) {
      return;
    }

    final fcmToken = await _messaging.getToken();
    if (fcmToken == null || fcmToken.isEmpty) {
      return;
    }

    try {
      await _apiClient.post(
        '/notifications/devices',
        body: {
          'token': fcmToken,
          'platform': _platform,
        },
      );
    } catch (_) {
      // Best effort; background re-sync can retry later.
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
