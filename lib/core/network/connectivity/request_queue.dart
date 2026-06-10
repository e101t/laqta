import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:laqta/core/network/connectivity/connectivity_service.dart';
import 'package:laqta/core/services/backend_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QueuedWriteRequest {
  const QueuedWriteRequest({
    required this.method,
    required this.path,
    required this.headers,
    required this.body,
    required this.createdAtMs,
  });

  final String method;
  final String path;
  final Map<String, String> headers;
  final String? body;
  final int createdAtMs;

  Map<String, dynamic> toJson() => {
    'method': method,
    'path': path,
    'headers': headers,
    'body': body,
    'createdAtMs': createdAtMs,
  };

  static QueuedWriteRequest fromJson(Map<String, dynamic> json) {
    return QueuedWriteRequest(
      method: json['method'] as String,
      path: json['path'] as String,
      headers: Map<String, String>.from(json['headers'] as Map),
      body: json['body'] as String?,
      createdAtMs: json['createdAtMs'] as int,
    );
  }
}

class RequestQueue {
  RequestQueue({
    ConnectivityService? connectivityService,
    http.Client? client,
    SharedPreferences? preferences,
  }) : _connectivityService = connectivityService ?? ConnectivityService(),
       _client = client ?? http.Client(),
       _preferences = preferences;

  static const int maxQueueSize = 20;
  static const String _storageKey = 'laqta_write_request_queue_v1';

  final ConnectivityService _connectivityService;
  final http.Client _client;
  SharedPreferences? _preferences;
  bool _flushing = false;

  Future<bool> enqueue(QueuedWriteRequest request) async {
    if (_isPaymentRequest(request.path)) {
      return false;
    }
    final prefs = await _prefs();
    final items = await _load();
    if (items.length >= maxQueueSize) {
      items.removeAt(0);
    }
    items.add(request);
    await prefs.setString(
      _storageKey,
      jsonEncode(items.map((item) => item.toJson()).toList()),
    );
    return true;
  }

  Future<int> pendingCount() async => (await _load()).length;

  Future<void> flushWhenOnline() async {
    final snapshot = await _connectivityService.checkNow();
    if (!snapshot.isOnline) return;
    await flush();
  }

  Future<void> flush() async {
    if (_flushing) return;
    _flushing = true;
    try {
      final prefs = await _prefs();
      final pending = await _load();
      final remaining = <QueuedWriteRequest>[];
      for (final request in pending) {
        final ok = await _send(request);
        if (!ok) remaining.add(request);
      }
      await prefs.setString(
        _storageKey,
        jsonEncode(remaining.map((item) => item.toJson()).toList()),
      );
    } finally {
      _flushing = false;
    }
  }

  Future<void> clear() async {
    final prefs = await _prefs();
    await prefs.remove(_storageKey);
  }

  Future<bool> _send(QueuedWriteRequest request) async {
    try {
      final uri = BackendConfig.apiUri(request.path);
      final method = request.method.toUpperCase();
      http.Response response;
      switch (method) {
        case 'POST':
          response = await _client.post(
            uri,
            headers: request.headers,
            body: request.body,
          );
          break;
        case 'PUT':
          response = await _client.put(
            uri,
            headers: request.headers,
            body: request.body,
          );
          break;
        case 'PATCH':
          response = await _client.patch(
            uri,
            headers: request.headers,
            body: request.body,
          );
          break;
        case 'DELETE':
          response = await _client.delete(uri, headers: request.headers);
          break;
        default:
          return true;
      }
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return false;
    }
  }

  Future<List<QueuedWriteRequest>> _load() async {
    final raw = (await _prefs()).getString(_storageKey);
    if (raw == null || raw.isEmpty) return <QueuedWriteRequest>[];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return <QueuedWriteRequest>[];
      return decoded
          .whereType<Map<dynamic, dynamic>>()
          .map(
            (item) =>
                QueuedWriteRequest.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
    } catch (_) {
      return <QueuedWriteRequest>[];
    }
  }

  Future<SharedPreferences> _prefs() async {
    return _preferences ??= await SharedPreferences.getInstance();
  }

  bool _isPaymentRequest(String path) {
    final lower = path.toLowerCase();
    return lower.contains('/payment') || lower.contains('/stripe');
  }
}
