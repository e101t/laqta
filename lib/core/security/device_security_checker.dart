import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class DeviceSecurityReport {
  const DeviceSecurityReport({
    required this.isRooted,
    required this.isEmulator,
    required this.isDebuggerAttached,
    required this.hasHookingFramework,
    required this.signatureValid,
    required this.warnings,
  });

  final bool isRooted;
  final bool isEmulator;
  final bool isDebuggerAttached;
  final bool hasHookingFramework;
  final bool? signatureValid;
  final List<String> warnings;

  bool get shouldWarnUser =>
      isRooted ||
      hasHookingFramework ||
      isDebuggerAttached ||
      signatureValid == false;

  factory DeviceSecurityReport.fromMap(Map<dynamic, dynamic> map) {
    final rawWarnings = map['warnings'];
    return DeviceSecurityReport(
      isRooted: map['isRooted'] == true,
      isEmulator: map['isEmulator'] == true,
      isDebuggerAttached: map['isDebuggerAttached'] == true,
      hasHookingFramework: map['hasHookingFramework'] == true,
      signatureValid: map['signatureValid'] is bool
          ? map['signatureValid'] as bool
          : null,
      warnings: rawWarnings is List
          ? rawWarnings.map((item) => item.toString()).toList(growable: false)
          : const <String>[],
    );
  }
}

class DeviceSecurityChecker {
  DeviceSecurityChecker._();

  static final ValueNotifier<DeviceSecurityReport?> latestReport =
      ValueNotifier<DeviceSecurityReport?>(null);
  static const MethodChannel _channel = MethodChannel('laqta/security/device');

  static Future<DeviceSecurityReport?> check() async {
    try {
      final result = await _channel
          .invokeMapMethod<dynamic, dynamic>('checkDeviceSecurity')
          .timeout(const Duration(seconds: 8));
      if (result == null) {
        return null;
      }
      final report = DeviceSecurityReport.fromMap(result);
      latestReport.value = report;
      return report;
    } catch (_) {
      return null;
    }
  }
}
