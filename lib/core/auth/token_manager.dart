import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:laqta/core/auth/jwt/jwt_validator.dart';
import 'package:laqta/core/config/app_config.dart';
import 'package:laqta/core/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenSnapshot {
  const TokenSnapshot({
    required this.accessToken,
    this.refreshToken,
    this.userId,
    this.accessTokenExpiresAt,
    this.refreshTokenExpiresAt,
  });

  final String accessToken;
  final String? refreshToken;
  final String? userId;
  final DateTime? accessTokenExpiresAt;
  final DateTime? refreshTokenExpiresAt;

  bool get hasRefreshToken => refreshToken != null && refreshToken!.isNotEmpty;
}

class TokenManager {
  TokenManager({FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  static const String _accessTokenKey = 'laqta.accessToken';
  static const String _refreshTokenKey = 'laqta.refreshToken';
  static const String _userIdKey = 'laqta.userId';
  static const String _accessExpiryKey = 'laqta.accessTokenExpiresAt';
  static const String _refreshExpiryKey = 'laqta.refreshTokenExpiresAt';
  static const String _sessionAppVersionKey = 'laqta.sessionAppVersion';
  static final JwtValidator _jwtValidator = JwtValidator(
    expectedIssuer: AppConfig.jwtIssuer,
    expectedAudience: AppConfig.jwtAudience,
  );

  final FlutterSecureStorage _secureStorage;

  Future<void> prepareForStartup({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    try {
      await _prepareForStartupInternal().timeout(timeout);
    } catch (_) {
      await clearAllTokens();
    }
  }

  Future<String?> getAccessToken() async {
    try {
      await _migrateLegacyTokenIfNeeded();
      final token = await _secureStorage.read(key: _accessTokenKey);
      if (token != null && token.isNotEmpty && !_isValidAccessToken(token)) {
        await clearAllTokens();
        return null;
      }
      return token;
    } catch (_) {
      await clearAllTokens();
      return null;
    }
  }

  Future<String?> getRefreshToken() async {
    try {
      await _migrateLegacyTokenIfNeeded();
      final token = await _secureStorage.read(key: _refreshTokenKey);
      if (token != null && token.isNotEmpty && !_isValidRefreshToken(token)) {
        await clearAllTokens();
        return null;
      }
      return token;
    } catch (_) {
      await clearAllTokens();
      return null;
    }
  }

  Future<String?> getUserId() async {
    try {
      await _migrateLegacyTokenIfNeeded();
      return _secureStorage.read(key: _userIdKey);
    } catch (_) {
      await clearAllTokens();
      return null;
    }
  }

  Future<TokenSnapshot?> readSnapshot() async {
    try {
      await _migrateLegacyTokenIfNeeded();
      final accessToken = await _secureStorage.read(key: _accessTokenKey);
      if (accessToken == null || accessToken.isEmpty) {
        return null;
      }
      if (!_isValidAccessToken(accessToken)) {
        await clearAllTokens();
        return null;
      }
      final refreshToken = await _secureStorage.read(key: _refreshTokenKey);
      if (refreshToken != null &&
          refreshToken.isNotEmpty &&
          !_isValidRefreshToken(refreshToken)) {
        await clearAllTokens();
        return null;
      }
      return TokenSnapshot(
        accessToken: accessToken,
        refreshToken: refreshToken,
        userId: await _secureStorage.read(key: _userIdKey),
        accessTokenExpiresAt: await _readDate(_accessExpiryKey),
        refreshTokenExpiresAt: await _readDate(_refreshExpiryKey),
      );
    } catch (_) {
      await clearAllTokens();
      return null;
    }
  }

  Future<bool> hasValidAccessToken({
    Duration skew = const Duration(minutes: 2),
  }) async {
    final snapshot = await readSnapshot();
    if (snapshot == null) {
      return false;
    }
    final expiry =
        snapshot.accessTokenExpiresAt ?? _readJwtExpiry(snapshot.accessToken);
    if (expiry == null) {
      return false;
    }
    return DateTime.now().isBefore(expiry.subtract(skew));
  }

  Future<bool> shouldRefreshAccessToken({
    Duration skew = const Duration(minutes: 2),
  }) async {
    final snapshot = await readSnapshot();
    if (snapshot == null || !snapshot.hasRefreshToken) {
      return false;
    }
    final refreshExpiry = snapshot.refreshTokenExpiresAt;
    if (refreshExpiry != null && DateTime.now().isAfter(refreshExpiry)) {
      return false;
    }
    final accessExpiry =
        snapshot.accessTokenExpiresAt ?? _readJwtExpiry(snapshot.accessToken);
    if (accessExpiry == null) {
      return false;
    }
    return DateTime.now().isAfter(accessExpiry.subtract(skew));
  }

  Future<bool> isTokenExpired(
    String token, {
    Duration skew = Duration.zero,
  }) async {
    if (!_isValidAccessToken(token)) {
      return true;
    }
    final expiry = _readJwtExpiry(token);
    if (expiry == null) {
      return true;
    }
    return !DateTime.now().isBefore(expiry.subtract(skew));
  }

  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
    String? userId,
    DateTime? accessTokenExpiresAt,
    DateTime? refreshTokenExpiresAt,
  }) async {
    final accessExpiry =
        accessTokenExpiresAt ??
        _readJwtExpiry(accessToken) ??
        DateTime.now().add(const Duration(minutes: 15));
    await _secureStorage.write(key: _accessTokenKey, value: accessToken);
    await _secureStorage.write(
      key: _accessExpiryKey,
      value: accessExpiry.toUtc().toIso8601String(),
    );

    if (refreshToken != null && refreshToken.isNotEmpty) {
      await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
      await _secureStorage.write(
        key: _refreshExpiryKey,
        value:
            (refreshTokenExpiresAt ??
                    DateTime.now().add(const Duration(days: 7)))
                .toUtc()
                .toIso8601String(),
      );
    }

    if (userId != null && userId.isNotEmpty) {
      await _secureStorage.write(key: _userIdKey, value: userId);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionAppVersionKey, AppConstants.appVersion);
    await prefs.remove(AppConstants.keyBackendJwt);
    await prefs.remove(AppConstants.keyBackendUserId);
  }

  Future<void> clearAllTokens() => clear();

  Future<void> clear() async {
    await _deleteSecureKey(_accessTokenKey);
    await _deleteSecureKey(_refreshTokenKey);
    await _deleteSecureKey(_userIdKey);
    await _deleteSecureKey(_accessExpiryKey);
    await _deleteSecureKey(_refreshExpiryKey);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.keyBackendJwt);
      await prefs.remove(AppConstants.keyBackendUserId);
    } catch (_) {
      // Session cleanup must never block app startup.
    }
  }

  Future<void> _prepareForStartupInternal() async {
    final prefs = await SharedPreferences.getInstance();
    final storedVersion = prefs.getString(_sessionAppVersionKey);
    if (storedVersion != AppConstants.appVersion) {
      await clearAllTokens();
      await prefs.setString(_sessionAppVersionKey, AppConstants.appVersion);
      return;
    }

    final token = await getAccessToken();
    if (token == null || token.isEmpty || await isTokenExpired(token)) {
      await clearAllTokens();
    }
  }

  Future<void> _migrateLegacyTokenIfNeeded() async {
    final existing = await _secureStorage.read(key: _accessTokenKey);
    if (existing != null && existing.isNotEmpty) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final legacyToken = prefs.getString(AppConstants.keyBackendJwt);
    if (legacyToken == null || legacyToken.isEmpty) {
      return;
    }

    await saveTokens(
      accessToken: legacyToken,
      userId: prefs.getString(AppConstants.keyBackendUserId),
    );
  }

  Future<DateTime?> _readDate(String key) async {
    try {
      final value = await _secureStorage.read(key: key);
      if (value == null || value.isEmpty) {
        return null;
      }
      return DateTime.tryParse(value)?.toLocal();
    } catch (_) {
      return null;
    }
  }

  Future<void> _deleteSecureKey(String key) async {
    try {
      await _secureStorage.delete(key: key);
    } catch (_) {
      // A corrupt Android keystore entry should not keep the app on splash.
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

  bool _isValidAccessToken(String token) {
    return _jwtValidator.validateAccessToken(token).isValid;
  }

  bool _isValidRefreshToken(String token) {
    return _jwtValidator.validateRefreshToken(token).isValid;
  }
}
