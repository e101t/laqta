import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:laqta/core/security/rasp/security_check_result.dart';
import 'package:laqta/core/security/rasp/security_platform_channel.dart';

class DebuggerDetector {
  DebuggerDetector({SecurityPlatformChannel? channel})
    : _channel = channel ?? SecurityPlatformChannel();

  final SecurityPlatformChannel _channel;

  Future<SecuritySignal> check() async {
    final vectors = <String>{};
    final details = <String, Object?>{};

    if (Platform.isAndroid || Platform.isIOS) {
      try {
        final native = await _channel.checkDebugger();
        vectors.addAll(_readStringList(native['vectors']));
        details.addAll(native);
      } catch (_) {
        // The Dart timing check below still runs.
      }
    }

    final stopwatch = Stopwatch()..start();
    var value = 0;
    for (var i = 0; i < 20000; i++) {
      value ^= i;
    }
    stopwatch.stop();
    details['timing_loop_value'] = value;
    details['timing_loop_ms'] = stopwatch.elapsedMilliseconds;
    if (kReleaseMode && stopwatch.elapsedMilliseconds > 100) {
      vectors.add('timing_attack_delta');
    }

    final detected = vectors.isNotEmpty;
    return SecuritySignal(
      name: 'debugger_detected',
      detected: detected,
      vectorCount: vectors.length,
      vectors: vectors.toList(growable: false),
      details: details,
      severity: detected ? SecuritySeverity.critical : SecuritySeverity.info,
    );
  }

  List<String> _readStringList(Object? value) {
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }
    return const <String>[];
  }
}
