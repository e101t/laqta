import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:laqta/core/auth/device/device_binder.dart';
import 'package:laqta/core/config/app_config.dart';
import 'package:laqta/core/constants/app_constants.dart';
import 'package:uuid/uuid.dart';

class RequestSigner {
  RequestSigner({
    FlutterSecureStorage? secureStorage,
    DeviceBinder? deviceBinder,
  }) : _secureStorage = secureStorage ?? const FlutterSecureStorage(),
       _deviceBinder = deviceBinder ?? DeviceBinder.instance;

  static const String _installIdKey = 'laqta.installId';
  static const Uuid _uuid = Uuid();

  final FlutterSecureStorage _secureStorage;
  final DeviceBinder _deviceBinder;

  Future<Map<String, String>> buildHeaders({
    required String method,
    required Uri uri,
    String? body,
    String? accessToken,
    bool sensitive = false,
  }) async {
    final requestId = _uuid.v4();
    final timestamp = DateTime.now().toUtc().millisecondsSinceEpoch.toString();
    final fingerprint = await _deviceHash();
    final deviceId = await _deviceBinder.deviceId();
    final bodyHash = sha256.convert(utf8.encode(body ?? '')).toString();
    final headers = <String, String>{
      'X-Request-ID': requestId,
      'X-Timestamp': timestamp,
      'X-App-Version': AppConstants.appVersion,
      'X-Device-Fingerprint': fingerprint,
      'X-Device-ID': deviceId,
      'X-Body-SHA256': bodyHash,
    };

    if (AppConfig.requestSigningEnabled && sensitive) {
      final signature = _signature(
        method: method,
        uri: uri,
        timestamp: timestamp,
        bodyHash: bodyHash,
        accessToken: accessToken,
      );
      if (signature != null) {
        headers['X-Signature'] = signature;
        headers['X-Request-Signature'] = signature;
      }
    }

    return headers;
  }

  Future<String> _deviceHash() async {
    var installId = await _secureStorage.read(key: _installIdKey);
    if (installId == null || installId.isEmpty) {
      installId = _uuid.v4();
      await _secureStorage.write(key: _installIdKey, value: installId);
    }
    return sha256.convert(utf8.encode('laqta:$installId')).toString();
  }

  String? _signature({
    required String method,
    required Uri uri,
    required String timestamp,
    required String bodyHash,
    required String? accessToken,
  }) {
    final configuredSecret = AppConfig.requestSigningSecret.trim();
    final keyMaterial = configuredSecret.isNotEmpty
        ? configuredSecret
        : (accessToken == null || accessToken.isEmpty ? null : accessToken);
    if (keyMaterial == null || keyMaterial.isEmpty) {
      return null;
    }

    final pathWithQuery = uri.hasQuery ? '${uri.path}?${uri.query}' : uri.path;
    final message = <String>[
      method.toUpperCase(),
      pathWithQuery,
      timestamp,
      bodyHash,
    ].join('\n');
    final hmac = Hmac(sha256, utf8.encode(keyMaterial));
    return base64Url.encode(hmac.convert(utf8.encode(message)).bytes);
  }
}

String generateNonce([int length = 32]) {
  final random = Random.secure();
  final bytes = List<int>.generate(length, (_) => random.nextInt(256));
  return base64Url.encode(bytes).replaceAll('=', '');
}

