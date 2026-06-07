import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:laqta/core/config/app_config.dart';
import 'package:laqta/core/services/backend_config.dart';

class CertificatePinningException implements Exception {
  const CertificatePinningException(this.host, this.message);

  final String host;
  final String message;

  @override
  String toString() => 'TLS pinning failed for $host: $message';
}

class CertificatePinning {
  CertificatePinning._();

  static final ValueNotifier<CertificatePinningException?> lastFailure =
      ValueNotifier<CertificatePinningException?>(null);

  static final Map<String, DateTime> _verifiedUntil = <String, DateTime>{};
  static final Set<String> _runtimePins = <String>{};
  static const Duration _cacheDuration = Duration(minutes: 10);

  static Set<String> get pinnedHosts {
    final hosts = <String>{};
    final apiHost = Uri.tryParse(BackendConfig.baseUrl)?.host;
    if (apiHost != null && apiHost.isNotEmpty) {
      hosts.add(apiHost);
    }
    hosts.add('api.laqta.cloud');
    for (final host in AppConfig.additionalPinnedHosts.split(',')) {
      final trimmed = host.trim();
      if (trimmed.isNotEmpty) {
        hosts.add(trimmed);
      }
    }
    return hosts;
  }

  static Set<String> get acceptedPins {
    return <String>{
      AppConfig.apiPrimaryPinSha256.trim(),
      AppConfig.apiBackupPinSha256.trim(),
      ..._runtimePins,
    }..removeWhere((pin) => pin.isEmpty);
  }

  static void addRuntimePin(String pin) {
    final normalized = pin.trim();
    if (normalized.isNotEmpty) {
      _runtimePins.add(normalized);
    }
  }

  static bool shouldPin(Uri uri) {
    return AppConfig.certificatePinningEnabled &&
        !AppConfig.disableCertificatePinning &&
        !const bool.fromEnvironment('DISABLE_PINNING', defaultValue: false) &&
        uri.scheme == 'https' &&
        pinnedHosts.contains(uri.host);
  }

  static Future<void> verifyHost(Uri uri) async {
    if (!shouldPin(uri)) {
      return;
    }

    final host = uri.host;
    final now = DateTime.now();
    final cachedUntil = _verifiedUntil[host];
    if (cachedUntil != null && cachedUntil.isAfter(now)) {
      return;
    }

    try {
      final socket = await SecureSocket.connect(
        host,
        uri.hasPort ? uri.port : 443,
        timeout: const Duration(seconds: 8),
      );
      try {
        final certificate = socket.peerCertificate;
        if (certificate == null) {
          throw const FormatException('No peer certificate was presented.');
        }
        final actualPin = _spkiSha256Pin(certificate.pem);
        if (!acceptedPins.contains(actualPin)) {
          throw CertificatePinningException(
            host,
            'SPKI pin mismatch. Actual pin: $actualPin',
          );
        }
        _verifiedUntil[host] = now.add(_cacheDuration);
        lastFailure.value = null;
      } finally {
        await socket.close();
      }
    } on CertificatePinningException catch (error) {
      lastFailure.value = error;
      rethrow;
    } on TimeoutException {
      lastFailure.value = null;
      return;
    } on SocketException {
      lastFailure.value = null;
      return;
    } catch (error) {
      final failure = CertificatePinningException(host, error.toString());
      lastFailure.value = failure;
      throw failure;
    }
  }

  static String _spkiSha256Pin(String pem) {
    final der = _pemToDer(pem);
    final spki = _extractSubjectPublicKeyInfo(der);
    return base64.encode(sha256.convert(spki).bytes);
  }

  static Uint8List _pemToDer(String pem) {
    final normalized = pem
        .replaceAll('-----BEGIN CERTIFICATE-----', '')
        .replaceAll('-----END CERTIFICATE-----', '')
        .replaceAll(RegExp(r'\s+'), '');
    return Uint8List.fromList(base64Decode(normalized));
  }

  static Uint8List _extractSubjectPublicKeyInfo(Uint8List certificateDer) {
    final certificate = _DerElement.read(certificateDer, 0);
    final tbsCertificate = _DerElement.read(
      certificateDer,
      certificate.valueStart,
    );
    var offset = tbsCertificate.valueStart;

    final first = _DerElement.read(certificateDer, offset);
    if (first.tag == 0xa0) {
      offset = first.end;
    }

    for (var i = 0; i < 5; i++) {
      offset = _DerElement.read(certificateDer, offset).end;
    }

    final spki = _DerElement.read(certificateDer, offset);
    return Uint8List.fromList(certificateDer.sublist(spki.start, spki.end));
  }
}

class PinnedHttpClient extends http.BaseClient {
  PinnedHttpClient({http.Client? inner}) : _inner = inner ?? http.Client();

  final http.Client _inner;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    await CertificatePinning.verifyHost(request.url);
    return _inner.send(request);
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }
}

class CertificatePinningMaintenanceGate extends StatelessWidget {
  const CertificatePinningMaintenanceGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<CertificatePinningException?>(
      valueListenable: CertificatePinning.lastFailure,
      builder: (context, failure, _) {
        if (failure == null) {
          return child;
        }
        return Material(
          color: const Color(0xFF090B0F),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.security_update_warning_rounded,
                      color: Color(0xFFE7B85A),
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'الخدمة قيد الصيانة الأمنية',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      kReleaseMode
                          ? 'تعذر التحقق من الاتصال الآمن. حاول لاحقًا.'
                          : failure.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xFF9CA3AF)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DerElement {
  const _DerElement({
    required this.tag,
    required this.start,
    required this.valueStart,
    required this.end,
  });

  final int tag;
  final int start;
  final int valueStart;
  final int end;

  static _DerElement read(Uint8List bytes, int offset) {
    final start = offset;
    final tag = bytes[offset++];
    final lengthByte = bytes[offset++];
    int length;
    if ((lengthByte & 0x80) == 0) {
      length = lengthByte;
    } else {
      final lengthBytes = lengthByte & 0x7f;
      if (lengthBytes == 0 || lengthBytes > 4) {
        throw const FormatException('Unsupported DER length.');
      }
      length = 0;
      for (var i = 0; i < lengthBytes; i++) {
        length = (length << 8) | bytes[offset++];
      }
    }
    final valueStart = offset;
    final end = valueStart + length;
    if (end > bytes.length) {
      throw const FormatException('Invalid DER element length.');
    }
    return _DerElement(
      tag: tag,
      start: start,
      valueStart: valueStart,
      end: end,
    );
  }
}
