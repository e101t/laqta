import 'package:flutter/services.dart';
import 'package:laqta/core/security/rasp/security_platform_channel.dart';

class ScreenSecurity {
  ScreenSecurity._();

  static final SecurityPlatformChannel _channel = SecurityPlatformChannel();

  static Future<void> enableSecureScreens() async {
    try {
      await _channel.enableFlagSecure();
    } on MissingPluginException {
      // Non-Android platforms can safely ignore this call.
    } catch (_) {
      // Screenshot prevention must not block app startup.
    }
  }
}
