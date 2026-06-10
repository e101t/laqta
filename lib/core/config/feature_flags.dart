import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:laqta/core/services/backend_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FeatureFlags {
  const FeatureFlags({
    required this.chatEnabled,
    required this.reelsEnabled,
    required this.storiesEnabled,
    required this.paymentsEnabled,
    required this.liveStreamsEnabled,
    required this.echocastEnabled,
  });

  final bool chatEnabled;
  final bool reelsEnabled;
  final bool storiesEnabled;
  final bool paymentsEnabled;
  final bool liveStreamsEnabled;
  final bool echocastEnabled;

  static FeatureFlags? _cached;

  static FeatureFlags get current => _cached ?? defaultFlags();

  static FeatureFlags defaultFlags() => const FeatureFlags(
    chatEnabled: true,
    reelsEnabled: true,
    storiesEnabled: true,
    paymentsEnabled: true,
    liveStreamsEnabled: false,
    echocastEnabled: false,
  );

  static void update(FeatureFlags flags) {
    _cached = flags;
  }

  factory FeatureFlags.fromJson(Map<String, dynamic> json) {
    return FeatureFlags(
      chatEnabled: json['chatEnabled'] as bool? ?? true,
      reelsEnabled: json['reelsEnabled'] as bool? ?? true,
      storiesEnabled: json['storiesEnabled'] as bool? ?? true,
      paymentsEnabled: json['paymentsEnabled'] as bool? ?? true,
      liveStreamsEnabled: json['liveStreamsEnabled'] as bool? ?? false,
      echocastEnabled: json['echocastEnabled'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'chatEnabled': chatEnabled,
    'reelsEnabled': reelsEnabled,
    'storiesEnabled': storiesEnabled,
    'paymentsEnabled': paymentsEnabled,
    'liveStreamsEnabled': liveStreamsEnabled,
    'echocastEnabled': echocastEnabled,
  };
}

class FeatureUnavailableWidgetData {
  const FeatureUnavailableWidgetData({required this.message});

  final String message;
}

class RemoteConfigService {
  RemoteConfigService({http.Client? client, SharedPreferences? preferences})
    : _client = client ?? http.Client(),
      _preferences = preferences;

  static const String _cacheKey = 'laqta_feature_flags_v1';
  static const String _cacheTimeKey = 'laqta_feature_flags_time_v1';
  static const Duration ttl = Duration(hours: 1);

  final http.Client _client;
  SharedPreferences? _preferences;

  Future<FeatureFlags> load() async {
    final cached = await _readCached();
    if (cached != null) {
      FeatureFlags.update(cached);
    }

    final shouldRefresh = await _shouldRefresh();
    if (!shouldRefresh && cached != null) {
      return cached;
    }

    try {
      final response = await _client
          .get(BackendConfig.apiUri('/config/features'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          final flags = FeatureFlags.fromJson(decoded);
          await _writeCached(flags);
          FeatureFlags.update(flags);
          return flags;
        }
      }
    } catch (_) {
      // Cached/default flags keep launch resilient.
    }

    final fallback = cached ?? FeatureFlags.defaultFlags();
    FeatureFlags.update(fallback);
    return fallback;
  }

  Future<FeatureFlags?> _readCached() async {
    final raw = (await _prefs()).getString(_cacheKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return FeatureFlags.fromJson(
        Map<String, dynamic>.from(jsonDecode(raw) as Map),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeCached(FeatureFlags flags) async {
    final prefs = await _prefs();
    await prefs.setString(_cacheKey, jsonEncode(flags.toJson()));
    await prefs.setInt(_cacheTimeKey, DateTime.now().millisecondsSinceEpoch);
  }

  Future<bool> _shouldRefresh() async {
    final last = (await _prefs()).getInt(_cacheTimeKey);
    if (last == null) return true;
    return DateTime.now().millisecondsSinceEpoch - last > ttl.inMilliseconds;
  }

  Future<SharedPreferences> _prefs() async {
    return _preferences ??= await SharedPreferences.getInstance();
  }
}
