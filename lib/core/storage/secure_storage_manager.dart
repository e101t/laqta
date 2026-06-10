import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecureStorageManager {
  SecureStorageManager({FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  static final SecureStorageManager instance = SecureStorageManager();

  static const Set<String> allowedPreferenceKeys = <String>{
    'language',
    'theme',
    'onboarding_seen',
    'reduceMotion',
    'notificationsEnabled',
  };

  final FlutterSecureStorage _secureStorage;
  final Map<String, Object?> _memoryCache = <String, Object?>{};

  Future<void> writeSecret(String key, String value) {
    return _secureStorage.write(key: key, value: value);
  }

  Future<String?> readSecret(String key) {
    return _secureStorage.read(key: key);
  }

  Future<void> deleteSecret(String key) {
    return _secureStorage.delete(key: key);
  }

  void writeSessionValue(String key, Object? value) {
    _memoryCache[key] = value;
  }

  T? readSessionValue<T>(String key) {
    final value = _memoryCache[key];
    return value is T ? value : null;
  }

  void clearMemoryTier() {
    _memoryCache.clear();
  }

  Future<void> writePreference(String key, String value) async {
    if (!allowedPreferenceKeys.contains(key)) {
      throw ArgumentError(
        'SharedPreferences key is not allowed for sensitive data: $key',
      );
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<void> wipeAll() async {
    clearMemoryTier();
    await _secureStorage.deleteAll();
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().toList(growable: false);
    for (final key in keys) {
      if (!allowedPreferenceKeys.contains(key)) {
        await prefs.remove(key);
      }
    }
  }
}
