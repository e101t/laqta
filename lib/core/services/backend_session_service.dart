import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:laqta/core/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackendSessionService {
  BackendSessionService({FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _secureStorage;

  Future<String?> getToken() {
    return _readWithLegacyMigration(AppConstants.keyBackendJwt);
  }

  Future<String?> getUserId() {
    return _readWithLegacyMigration(AppConstants.keyBackendUserId);
  }

  Future<bool> hasValidToken() async {
    final token = await getToken();
    if (token == null || token.isEmpty) {
      return false;
    }

    final expiry = _readJwtExpiry(token);
    if (expiry == null) {
      return true;
    }

    return DateTime.now().isBefore(expiry.subtract(const Duration(minutes: 1)));
  }

  Future<void> saveSession({required String token, String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    final tokenStoredSecurely = await _safeWrite(
      AppConstants.keyBackendJwt,
      token,
    );
    if (tokenStoredSecurely) {
      await prefs.remove(AppConstants.keyBackendJwt);
    } else {
      await prefs.setString(AppConstants.keyBackendJwt, token);
    }

    if (userId != null && userId.isNotEmpty) {
      final userIdStoredSecurely = await _safeWrite(
        AppConstants.keyBackendUserId,
        userId,
      );
      if (userIdStoredSecurely) {
        await prefs.remove(AppConstants.keyBackendUserId);
      } else {
        await prefs.setString(AppConstants.keyBackendUserId, userId);
      }
    }
  }

  Future<void> clear() async {
    await _safeDelete(AppConstants.keyBackendJwt);
    await _safeDelete(AppConstants.keyBackendUserId);

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.keyBackendJwt);
    await prefs.remove(AppConstants.keyBackendUserId);
  }

  Future<String?> _readWithLegacyMigration(String key) async {
    final secureValue = await _safeRead(key);
    if (secureValue != null && secureValue.isNotEmpty) {
      return secureValue;
    }

    final prefs = await SharedPreferences.getInstance();
    final legacyValue = prefs.getString(key);
    if (legacyValue == null || legacyValue.isEmpty) {
      return null;
    }

    final migratedToSecureStorage = await _safeWrite(key, legacyValue);
    if (migratedToSecureStorage) {
      await prefs.remove(key);
    }
    return legacyValue;
  }

  Future<String?> _safeRead(String key) async {
    try {
      return await _secureStorage.read(key: key);
    } catch (_) {
      return null;
    }
  }

  Future<bool> _safeWrite(String key, String value) async {
    try {
      await _secureStorage.write(key: key, value: value);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _safeDelete(String key) async {
    try {
      await _secureStorage.delete(key: key);
    } catch (_) {
      // Ignore and keep SharedPreferences cleanup below as the fallback.
    }
  }

  DateTime? _readJwtExpiry(String token) {
    final parts = token.split('.');
    if (parts.length < 2) {
      return null;
    }

    try {
      final normalized = base64.normalize(parts[1]);
      final payload = utf8.decode(base64Url.decode(normalized));
      final decoded = jsonDecode(payload);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      final exp = decoded['exp'];
      if (exp is int) {
        return DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      }
      if (exp is num) {
        return DateTime.fromMillisecondsSinceEpoch(exp.toInt() * 1000);
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
