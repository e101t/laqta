import 'dart:io';

import 'package:laqta/core/security/rasp/security_check_result.dart';
import 'package:laqta/core/security/rasp/security_platform_channel.dart';

class IntegrityVerifier {
  IntegrityVerifier({SecurityPlatformChannel? channel})
    : _channel = channel ?? SecurityPlatformChannel();

  static const String expectedPackageName = 'com.laqta.laqta';

  final SecurityPlatformChannel _channel;

  Future<SecuritySignal> check() async {
    if (!Platform.isAndroid) {
      return const SecuritySignal(name: 'tampered_apk', detected: false);
    }

    try {
      final native = await _channel.verifyIntegrity();
      final vectors = _readStringList(native['vectors']);
      final packageName = native['packageName']?.toString() ?? '';
      if (packageName.isNotEmpty && packageName != expectedPackageName) {
        vectors.add('package_name_mismatch');
      }
      final detected = vectors.any(
        (vector) =>
            vector == 'signature_mismatch' || vector == 'package_name_mismatch',
      );
      return SecuritySignal(
        name: 'tampered_apk',
        detected: detected,
        vectorCount: vectors.length,
        vectors: vectors,
        details: native,
        severity: detected ? SecuritySeverity.critical : SecuritySeverity.info,
      );
    } catch (error) {
      return SecuritySignal(
        name: 'tampered_apk',
        detected: false,
        details: <String, Object?>{'error': error.toString()},
      );
    }
  }

  List<String> _readStringList(Object? value) {
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }
    return <String>[];
  }
}
