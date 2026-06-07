import 'dart:async';

import 'package:flutter/services.dart';

class ClipboardGuard {
  ClipboardGuard._();

  static Timer? _clearTimer;

  static Future<void> copySensitive(String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    _clearTimer?.cancel();
    _clearTimer = Timer(const Duration(seconds: 60), () async {
      final current = await Clipboard.getData('text/plain');
      if (current?.text == value) {
        await Clipboard.setData(const ClipboardData(text: ''));
      }
    });
  }

  static String sanitizePastedText(String value) {
    return value.replaceAll(RegExp(r'[\u202A-\u202E\u2066-\u2069]'), '').trim();
  }
}
