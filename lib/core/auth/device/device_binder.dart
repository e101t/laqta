import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

class DeviceBinder {
  DeviceBinder({FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  static final DeviceBinder instance = DeviceBinder();
  static const String _installUuidKey = 'laqta.device.installUuid';
  static const Uuid _uuid = Uuid();

  final FlutterSecureStorage _secureStorage;

  Future<String> deviceId() async {
    var installUuid = await _secureStorage.read(key: _installUuidKey);
    if (installUuid == null || installUuid.isEmpty) {
      installUuid = _uuid.v4();
      await _secureStorage.write(key: _installUuidKey, value: installUuid);
    }
    return sha256
        .convert(utf8.encode(_fingerprintMaterial(installUuid)))
        .toString();
  }

  Future<Map<String, String>> headers() async {
    return <String, String>{'X-Device-ID': await deviceId()};
  }

  String _fingerprintMaterial(String installUuid) {
    final platform = kIsWeb ? 'web' : Platform.operatingSystem;
    final version = kIsWeb ? 'web' : Platform.operatingSystemVersion;
    final target = defaultTargetPlatform.name;
    return '$platform|$version|$target|$installUuid';
  }
}
