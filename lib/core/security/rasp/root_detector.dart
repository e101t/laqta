import 'dart:io';

import 'package:laqta/core/security/rasp/security_check_result.dart';
import 'package:laqta/core/security/rasp/security_platform_channel.dart';

class RootDetector {
  RootDetector({SecurityPlatformChannel? channel})
    : _channel = channel ?? SecurityPlatformChannel();

  static const suPaths = <String>[
    '/system/bin/su',
    '/system/xbin/su',
    '/sbin/su',
    '/system/sd/xbin/su',
    '/system/bin/failsafe/su',
    '/data/local/xbin/su',
    '/data/local/bin/su',
    '/data/local/su',
  ];

  static const busyboxPaths = <String>[
    '/system/bin/busybox',
    '/system/xbin/busybox',
    '/sbin/busybox',
    '/vendor/bin/busybox',
    '/data/local/busybox',
  ];

  final SecurityPlatformChannel _channel;

  Future<SecuritySignal> check() async {
    final vectors = <String>{};
    final details = <String, Object?>{};

    if (Platform.isAndroid) {
      try {
        final native = await _channel.checkRoot();
        vectors.addAll(_readStringList(native['vectors']));
        details.addAll(native);
      } catch (_) {
        // Local checks below keep detection working if the channel is unavailable.
      }
    }

    for (final path in suPaths) {
      if (File(path).existsSync()) {
        vectors.add('su_binary:$path');
      }
    }

    for (final path in busyboxPaths) {
      if (File(path).existsSync()) {
        vectors.add('busybox:$path');
      }
    }

    if (File('/system/app/Superuser.apk').existsSync()) {
      vectors.add('superuser_apk');
    }

    final count = vectors.length;
    return SecuritySignal(
      name: 'root_detected',
      detected: count > 0,
      vectorCount: count,
      vectors: vectors.toList(growable: false),
      details: details,
      severity: count >= 2
          ? SecuritySeverity.critical
          : SecuritySeverity.warning,
    );
  }

  List<String> _readStringList(Object? value) {
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }
    return const <String>[];
  }
}
