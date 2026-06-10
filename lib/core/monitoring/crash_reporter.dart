import 'dart:convert';
import 'dart:developer' as developer;

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

class CrashReporter {
  CrashReporter._();

  static final CrashReporter instance = CrashReporter._();

  String? _hashedUserId;
  final Map<String, Object?> _customKeys = <String, Object?>{};

  static void logFatal(Object error, StackTrace? stackTrace, {String? screen}) {
    instance.recordError(
      error,
      stackTrace ?? StackTrace.current,
      screen: screen,
    );
  }

  static void logError(
    String tag,
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    instance.setCustomKey('tag', tag);
    instance.recordError(
      error ?? message,
      stackTrace ?? StackTrace.current,
      screen: tag,
    );
  }

  static Future<String> reportError(
    Object error,
    StackTrace? stackTrace,
  ) async {
    final id = DateTime.now().microsecondsSinceEpoch.toRadixString(16);
    instance.setCustomKey('error_id', id);
    logFatal(error, stackTrace);
    return id;
  }

  void setUserId(String? userId) {
    if (userId == null || userId.isEmpty) {
      _hashedUserId = null;
      return;
    }
    _hashedUserId = sha256.convert(utf8.encode(userId)).toString();
  }

  void setCustomKey(String key, Object? value) {
    if (_isSensitiveKey(key)) {
      return;
    }
    _customKeys[key] = _redact(value);
  }

  void recordError(Object error, StackTrace stackTrace, {String? screen}) {
    if (screen != null) {
      setCustomKey('screen', screen);
    }
    if (kDebugMode) {
      developer.log(
        'CrashReporter user=$_hashedUserId keys=$_customKeys error=${_redact(error)}',
        name: 'LAQTA',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Object? _redact(Object? value) {
    if (value is Uri) {
      return _redactUrl(value.toString());
    }
    if (value is String) {
      return _redactUrl(value)
          .replaceAll(
            RegExp(
              r'(token|password|secret|client_secret)=([^&\s]+)',
              caseSensitive: false,
            ),
            r'$1=REDACTED',
          )
          .replaceAll(RegExp(r'Bearer\s+[A-Za-z0-9._-]+'), 'Bearer REDACTED');
    }
    return value;
  }

  String _redactUrl(String value) {
    return value.replaceAll(
      RegExp(
        r'([?&](token|password|secret|client_secret)=)[^&]+',
        caseSensitive: false,
      ),
      r'$1REDACTED',
    );
  }

  bool _isSensitiveKey(String key) {
    final lower = key.toLowerCase();
    return lower.contains('token') ||
        lower.contains('password') ||
        lower.contains('secret') ||
        lower.contains('payment');
  }
}
