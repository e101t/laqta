import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class CachedApiResponse {
  const CachedApiResponse({
    required this.statusCode,
    required this.headers,
    required this.body,
    required this.cachedAtMs,
    required this.ttlMs,
  });

  final int statusCode;
  final Map<String, String> headers;
  final String body;
  final int cachedAtMs;
  final int ttlMs;

  bool get isFresh =>
      DateTime.now().millisecondsSinceEpoch - cachedAtMs <= ttlMs;

  Map<String, dynamic> toJson() => {
    'statusCode': statusCode,
    'headers': headers,
    'body': body,
    'cachedAtMs': cachedAtMs,
    'ttlMs': ttlMs,
  };

  static CachedApiResponse fromJson(Map<String, dynamic> json) {
    return CachedApiResponse(
      statusCode: json['statusCode'] as int,
      headers: Map<String, String>.from(json['headers'] as Map),
      body: json['body'] as String,
      cachedAtMs: json['cachedAtMs'] as int,
      ttlMs: json['ttlMs'] as int,
    );
  }
}

class ResponseCache {
  ResponseCache({SharedPreferences? preferences}) : _preferences = preferences;

  static const String _prefix = 'laqta_response_cache_v1:';
  SharedPreferences? _preferences;

  Future<void> put(String key, CachedApiResponse response) async {
    final prefs = await _prefs();
    await prefs.setString('$_prefix$key', jsonEncode(response.toJson()));
  }

  Future<CachedApiResponse?> get(String key) async {
    final raw = (await _prefs()).getString('$_prefix$key');
    if (raw == null || raw.isEmpty) return null;
    try {
      return CachedApiResponse.fromJson(
        Map<String, dynamic>.from(jsonDecode(raw) as Map),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> remove(String key) async {
    await (await _prefs()).remove('$_prefix$key');
  }

  Future<void> clearUserCache() async {
    final prefs = await _prefs();
    final keys = prefs.getKeys().where((key) => key.startsWith(_prefix));
    for (final key in keys) {
      await prefs.remove(key);
    }
  }

  Future<SharedPreferences> _prefs() async {
    return _preferences ??= await SharedPreferences.getInstance();
  }
}
