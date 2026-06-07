import 'dart:convert';

import 'package:laqta/core/auth/device/device_binder.dart';
import 'package:laqta/core/services/backend_api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AnalyticsService {
  AnalyticsService._();

  static final AnalyticsService instance = AnalyticsService._();
  static const _queueKey = 'laqta_analytics_queue_v1';

  final BackendApiClient _apiClient = BackendApiClient();

  Future<void> track(
    String eventName, {
    String? screen,
    Map<String, Object?> properties = const <String, Object?>{},
  }) async {
    final event = <String, dynamic>{
      'anonymousId': await DeviceBinder.instance.deviceId(),
      'eventName': eventName,
    };
    if (screen != null) {
      event['screen'] = screen;
    }
    if (properties.isNotEmpty) {
      event['properties'] = _sanitize(properties);
    }

    await _enqueue(event);
    await flush();
  }

  Future<void> flush() async {
    final prefs = await SharedPreferences.getInstance();
    final queued = prefs.getStringList(_queueKey) ?? const <String>[];
    if (queued.isEmpty) {
      return;
    }

    final events = queued
        .map((raw) => jsonDecode(raw))
        .whereType<Map<String, dynamic>>()
        .take(50)
        .toList(growable: false);
    if (events.isEmpty) {
      await prefs.remove(_queueKey);
      return;
    }

    try {
      await _apiClient.post(
        '/analytics/events',
        body: <String, dynamic>{'events': events},
        authorized: false,
      );
      final remaining = queued.skip(events.length).toList(growable: false);
      await prefs.setStringList(_queueKey, remaining);
    } catch (_) {
      // Keep queue for offline retry.
    }
  }

  Future<void> _enqueue(Map<String, dynamic> event) async {
    final prefs = await SharedPreferences.getInstance();
    final queued = prefs.getStringList(_queueKey) ?? <String>[];
    queued.add(jsonEncode(event));
    final trimmed = queued.length > 100
        ? queued.sublist(queued.length - 100)
        : queued;
    await prefs.setStringList(_queueKey, trimmed);
  }

  Map<String, Object?> _sanitize(Map<String, Object?> input) {
    const blocked = <String>{
      'name',
      'phone',
      'email',
      'token',
      'password',
      'authorization',
      'payment',
      'card',
    };

    return Map<String, Object?>.fromEntries(
      input.entries.where(
        (entry) => !blocked.contains(entry.key.toLowerCase()),
      ),
    );
  }
}
