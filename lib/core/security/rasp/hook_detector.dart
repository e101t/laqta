import 'dart:io';

import 'package:laqta/core/security/rasp/security_check_result.dart';
import 'package:laqta/core/security/rasp/security_platform_channel.dart';

class HookDetector {
  HookDetector({SecurityPlatformChannel? channel})
    : _channel = channel ?? SecurityPlatformChannel();

  final SecurityPlatformChannel _channel;

  Future<SecuritySignal> check() async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      return const SecuritySignal(name: 'hook_detected', detected: false);
    }

    try {
      final native = await _channel.checkHooking();
      final vectors = _readStringList(native['vectors']);
      final detected = vectors.isNotEmpty || native['detected'] == true;
      return SecuritySignal(
        name: 'hook_detected',
        detected: detected,
        vectorCount: vectors.length,
        vectors: vectors,
        details: native,
        severity: detected ? SecuritySeverity.critical : SecuritySeverity.info,
      );
    } catch (error) {
      return SecuritySignal(
        name: 'hook_detected',
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
