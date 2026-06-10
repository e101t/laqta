import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:laqta/core/security/rasp/security_check_result.dart';
import 'package:laqta/core/security/rasp/security_platform_channel.dart';

class EmulatorDetector {
  EmulatorDetector({SecurityPlatformChannel? channel})
    : _channel = channel ?? SecurityPlatformChannel();

  final SecurityPlatformChannel _channel;

  Future<SecuritySignal> check() async {
    if (!Platform.isAndroid) {
      return const SecuritySignal(name: 'emulator_detected', detected: false);
    }

    try {
      final native = await _channel.checkEmulator();
      final vectors = _readStringList(native['vectors']);
      final detected = vectors.isNotEmpty || native['detected'] == true;
      return SecuritySignal(
        name: 'emulator_detected',
        detected: detected,
        vectorCount: vectors.length,
        vectors: vectors,
        details: native,
        severity: kReleaseMode && detected
            ? SecuritySeverity.critical
            : SecuritySeverity.warning,
      );
    } catch (error) {
      return SecuritySignal(
        name: 'emulator_detected',
        detected: false,
        details: <String, Object?>{'error': error.toString()},
      );
    }
  }

  List<String> _readStringList(Object? value) {
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }
    return const <String>[];
  }
}
