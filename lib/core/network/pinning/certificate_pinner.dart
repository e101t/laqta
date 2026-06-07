import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:laqta/core/config/app_config.dart';
import 'package:laqta/core/network/certificate_pinning.dart' as legacy;
import 'package:laqta/core/services/backend_config.dart';
import 'package:laqta/core/security/monitoring/security_event_logger.dart';

class CertificatePinner {
  CertificatePinner({
    SecurityEventLogger? logger,
    FlutterSecureStorage? secureStorage,
    http.Client? client,
  }) : _logger = logger ?? SecurityEventLogger.instance,
       _secureStorage = secureStorage ?? const FlutterSecureStorage(),
       _client = client ?? http.Client();

  static const bool _disablePinning = bool.fromEnvironment(
    'DISABLE_PINNING',
    defaultValue: false,
  );

  final SecurityEventLogger _logger;
  final FlutterSecureStorage _secureStorage;
  final http.Client _client;

  ValueListenable<legacy.CertificatePinningException?> get lastFailure =>
      legacy.CertificatePinning.lastFailure;

  Future<void> verifyHost(Uri uri) async {
    if (_disablePinning || AppConfig.disableCertificatePinning) {
      return;
    }
    try {
      await legacy.CertificatePinning.verifyHost(uri);
    } on legacy.CertificatePinningException catch (error) {
      await _logger.log(
        'pin_mismatch',
        severity: 'critical',
        details: <String, Object?>{
          'host': error.host,
          'message': error.message,
        },
      );
      rethrow;
    }
  }

  Future<void> refreshRotatedPins() async {
    try {
      final stored = await _secureStorage.read(
        key: 'laqta.security.runtimePins',
      );
      if (stored != null && stored.isNotEmpty) {
        final decoded = jsonDecode(stored);
        if (decoded is List) {
          for (final pin in decoded) {
            legacy.CertificatePinning.addRuntimePin(pin.toString());
          }
        }
      }

      final response = await _client
          .get(
            BackendConfig.apiUri('/security/pins'),
            headers: const <String, String>{'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 4));
      if (response.statusCode < 200 ||
          response.statusCode >= 300 ||
          response.body.isEmpty) {
        return;
      }
      final decoded = jsonDecode(response.body);
      final rawPins = decoded is Map<String, dynamic> ? decoded['pins'] : null;
      if (rawPins is! List) {
        return;
      }
      final pins = rawPins
          .map((pin) => pin.toString().trim())
          .where((pin) => pin.isNotEmpty)
          .toList(growable: false);
      for (final pin in pins) {
        legacy.CertificatePinning.addRuntimePin(pin);
      }
      await _secureStorage.write(
        key: 'laqta.security.runtimePins',
        value: jsonEncode(pins),
      );
    } catch (_) {
      // Rotation endpoint is optional and must not break app startup.
    }
  }

  Future<void> verifyBackend() => verifyHost(BackendConfig.apiUri('/health'));
}

class PinningHttpClient extends http.BaseClient {
  PinningHttpClient({http.Client? inner, CertificatePinner? pinner})
    : _inner = inner ?? http.Client(),
      _pinner = pinner ?? CertificatePinner();

  final http.Client _inner;
  final CertificatePinner _pinner;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    await _pinner.verifyHost(request.url);
    return _inner.send(request);
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }
}
