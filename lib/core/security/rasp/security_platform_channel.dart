import 'package:flutter/services.dart';

class SecurityPlatformChannel {
  SecurityPlatformChannel({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel('laqta/security/rasp');

  final MethodChannel _channel;

  Future<Map<String, Object?>> checkRoot() => _invokeMap('checkRoot');

  Future<Map<String, Object?>> checkEmulator() => _invokeMap('checkEmulator');

  Future<Map<String, Object?>> checkHooking() => _invokeMap('checkHooking');

  Future<Map<String, Object?>> checkDebugger() => _invokeMap('checkDebugger');

  Future<Map<String, Object?>> verifyIntegrity() =>
      _invokeMap('verifyIntegrity');

  Future<void> enableFlagSecure() async {
    await _channel.invokeMethod<void>('enableFlagSecure');
  }

  Future<Map<String, Object?>> _invokeMap(String method) async {
    final value = await _channel.invokeMethod<Object?>(method);
    if (value is Map) {
      return value.map((key, value) => MapEntry(key.toString(), value));
    }
    return <String, Object?>{};
  }
}
