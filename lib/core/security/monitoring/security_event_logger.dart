import 'dart:async';
import 'package:laqta/core/logging/app_logger.dart';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:laqta/core/auth/device/device_binder.dart';
import 'package:laqta/core/config/app_config.dart';
import 'package:laqta/core/constants/app_constants.dart';
import 'package:laqta/core/services/backend_config.dart';

class SecurityEventLogger {
  SecurityEventLogger({http.Client? client, DeviceBinder? deviceBinder})
    : _client = client ?? http.Client(),
      _deviceBinder = deviceBinder ?? DeviceBinder.instance;

  static final SecurityEventLogger instance = SecurityEventLogger();

  final http.Client _client;
  final DeviceBinder _deviceBinder;

  Future<void> log(
    String eventType, {
    String severity = 'warning',
    Map<String, Object?> details = const <String, Object?>{},
  }) async {
    if (!AppConfig.securityEventsEnabled) {
      return;
    }
    try {
      final payload = <String, Object?>{
        'event_type': eventType,
        'timestamp_ms': DateTime.now().millisecondsSinceEpoch,
        'device_fingerprint': await _deviceHash(),
        'app_version': AppConstants.appVersion,
        'build_number': const String.fromEnvironment(
          'BUILD_NUMBER',
          defaultValue: '1',
        ),
        'severity': severity,
        'details': details,
      };
      await _client
          .post(
            BackendConfig.apiUri('/security/events'),
            headers: const <String, String>{
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 4));
    } catch (error) {
      if (kDebugMode) {
        AppLogger.d('runtime', 'Security event log failed: $error');
      }
    }
  }

  Future<String> _deviceHash() async {
    final deviceId = await _deviceBinder.deviceId();
    return sha256.convert(utf8.encode('laqta:$deviceId')).toString();
  }
}


