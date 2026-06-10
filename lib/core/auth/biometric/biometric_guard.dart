import 'dart:async';

import 'package:flutter/services.dart';
import 'package:laqta/core/config/app_config.dart';

class BiometricGuard {
  BiometricGuard({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel('laqta/security/biometric');

  static final BiometricGuard instance = BiometricGuard();

  final MethodChannel _channel;
  DateTime? _backgroundedAt;
  int _failedAttempts = 0;

  void markBackgrounded() {
    _backgroundedAt = DateTime.now();
  }

  bool get requiresReauthAfterBackground {
    final backgroundedAt = _backgroundedAt;
    if (backgroundedAt == null) {
      return false;
    }
    return DateTime.now().difference(backgroundedAt) >=
        Duration(minutes: AppConfig.biometricBackgroundMinutes);
  }

  Future<bool> authenticate({
    String reason = 'يرجى تأكيد هويتك للمتابعة',
  }) async {
    if (_failedAttempts >= 3) {
      return false;
    }
    try {
      final result = await _channel
          .invokeMethod<bool>('authenticate', <String, Object?>{
            'reason': reason,
          })
          .timeout(const Duration(seconds: 20));
      if (result == true) {
        _failedAttempts = 0;
        return true;
      }
      _failedAttempts += 1;
      return false;
    } on MissingPluginException {
      // Biometric plugin/channel is optional until native enrollment is enabled.
      return true;
    } on TimeoutException {
      _failedAttempts += 1;
      return false;
    } catch (_) {
      _failedAttempts += 1;
      return false;
    }
  }
}
