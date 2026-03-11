import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:luqta/app/router/app_router.dart';
import 'package:luqta/app/router/routes.dart';
import 'package:luqta/features/notifications/notifications_dependencies.dart';
import 'package:luqta/features/notifications/domain/entities/notification_model.dart';

class NotificationNavigationService {
  NotificationNavigationService._();

  static final NotificationNavigationService instance =
      NotificationNavigationService._();

  RemoteMessage? _pendingLaunchMessage;
  StreamSubscription<RemoteMessage>? _messageOpenedSubscription;
  String? _lastHandledMessageId;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    _initialized = true;
    _pendingLaunchMessage = await FirebaseMessaging.instance.getInitialMessage();
    _messageOpenedSubscription = FirebaseMessaging.onMessageOpenedApp.listen(
      _handleRemoteMessage,
    );
  }

  void flushPendingLaunchMessage() {
    final message = _pendingLaunchMessage;
    if (message == null) {
      return;
    }

    _pendingLaunchMessage = null;
    _handleRemoteMessage(message);
  }

  void openNotificationModel(NotificationModel notification) {
    final path = resolveNotificationPath(
      type: notification.type,
      data: notification.data,
      actionUrl: notification.actionUrl,
    );
    if (path == Routes.notifications) {
      return;
    }
    _navigateTo(path);
  }

  @visibleForTesting
  static String resolveNotificationPath({
    String? type,
    Map<String, dynamic>? data,
    String? actionUrl,
  }) {
    final normalizedAction = _normalizeAppRoute(actionUrl);
    if (normalizedAction != null) {
      return normalizedAction;
    }

    final route =
        _readString(data, 'route') ??
        _readString(data, 'path') ??
        _readString(data, 'actionUrl');
    final normalizedRoute = _normalizeAppRoute(route);
    if (normalizedRoute != null) {
      return normalizedRoute;
    }

    final chatId = _readString(data, 'chatId');
    if (chatId != null && chatId.isNotEmpty) {
      final otherUserName =
          _readString(data, 'otherUserName') ?? _readString(data, 'name') ?? '';
      return _buildChatPath(chatId, otherUserName);
    }

    final bookingId = _readString(data, 'bookingId');
    if (bookingId != null && bookingId.isNotEmpty) {
      return Routes.booking.replaceFirst(':id', Uri.encodeComponent(bookingId));
    }

    final requestId = _readString(data, 'requestId');
    if (requestId != null && requestId.isNotEmpty) {
      return Routes.requestDetails.replaceFirst(
        ':id',
        Uri.encodeComponent(requestId),
      );
    }

    final photographerId = _readString(data, 'photographerId');
    if (photographerId != null && photographerId.isNotEmpty) {
      return Routes.photographer.replaceFirst(
        ':id',
        Uri.encodeComponent(photographerId),
      );
    }

    switch ((type ?? '').trim()) {
      case 'message':
        return Routes.main;
      default:
        return Routes.notifications;
    }
  }

  Future<void> dispose() async {
    await _messageOpenedSubscription?.cancel();
    _messageOpenedSubscription = null;
    _initialized = false;
    _pendingLaunchMessage = null;
    _lastHandledMessageId = null;
  }

  void _handleRemoteMessage(RemoteMessage message) {
    unawaited(_openRemoteMessage(message));
  }

  Future<void> _openRemoteMessage(RemoteMessage message) async {
    final messageId = message.messageId;
    if (messageId != null && messageId == _lastHandledMessageId) {
      return;
    }
    _lastHandledMessageId = messageId;

    await _markNotificationAsRead(_readNotificationId(message.data));

    final path = resolveNotificationPath(
      type: message.data['type'],
      data: message.data,
    );
    _navigateTo(path);
  }

  void _navigateTo(String path) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(AppRouter.router.push(path));
    });
  }

  static String? _normalizeAppRoute(String? value) {
    if (value == null) {
      return null;
    }

    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    if (trimmed.startsWith('/')) {
      return trimmed;
    }

    final parsed = Uri.tryParse(trimmed);
    if (parsed != null && !parsed.hasScheme && parsed.path.startsWith('/')) {
      return parsed.toString();
    }

    return null;
  }

  static String? _readString(Map<String, dynamic>? data, String key) {
    if (data == null) {
      return null;
    }

    final value = data[key];
    if (value is String) {
      final trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }

    return null;
  }

  static String? _readNotificationId(Map<String, dynamic>? data) {
    return _readString(data, 'notificationId') ?? _readString(data, 'id');
  }

  Future<void> _markNotificationAsRead(String? notificationId) async {
    if (notificationId == null || notificationId.isEmpty) {
      return;
    }

    final result = await NotificationsDependencies.markNotificationRead().call(
      notificationId,
    );
    if (!result.isSuccess) {
      return;
    }
  }

  static String _buildChatPath(String chatId, String otherUserName) {
    final path = Routes.chat.replaceFirst(':id', Uri.encodeComponent(chatId));
    if (otherUserName.trim().isEmpty) {
      return path;
    }

    final encodedName = Uri.encodeComponent(otherUserName.trim());
    return '$path?name=$encodedName';
  }
}
