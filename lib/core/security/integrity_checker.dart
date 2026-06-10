import 'dart:async';

import 'package:flutter/services.dart';
import 'package:laqta/core/config/app_config.dart';
import 'package:laqta/core/network/request_signer.dart';
import 'package:laqta/core/services/backend_api_client.dart';

class IntegrityCheckResult {
  const IntegrityCheckResult({required this.available, this.token, this.error});

  final bool available;
  final String? token;
  final Object? error;
}

class IntegrityChecker {
  IntegrityChecker._({BackendApiClient? apiClient})
    : _apiClient = apiClient ?? BackendApiClient();

  static final IntegrityChecker instance = IntegrityChecker._();
  static const MethodChannel _channel = MethodChannel(
    'laqta/security/integrity',
  );

  final BackendApiClient _apiClient;
  IntegrityCheckResult? _lastResult;

  Future<IntegrityCheckResult> warmUp() async {
    _lastResult = await requestToken();
    return _lastResult!;
  }

  Future<IntegrityCheckResult> requestToken({String? nonce}) async {
    try {
      final token = await _channel
          .invokeMethod<String>('requestIntegrityToken', {
            'nonce': nonce ?? generateNonce(),
            'cloudProjectNumber': AppConfig.playIntegrityCloudProjectNumber,
          })
          .timeout(const Duration(seconds: 12));
      return IntegrityCheckResult(
        available: token != null && token.isNotEmpty,
        token: token,
      );
    } catch (error) {
      return IntegrityCheckResult(available: false, error: error);
    }
  }

  Future<void> verifyForOperation(String operation) async {
    final result = _lastResult?.available == true
        ? _lastResult!
        : await requestToken();
    _lastResult = result;

    if (!result.available || result.token == null) {
      if (AppConfig.playIntegrityRequired) {
        throw StateError('Play Integrity token unavailable for $operation.');
      }
      return;
    }

    try {
      await _apiClient.post(
        AppConfig.playIntegrityVerifyPath,
        authorized: false,
        body: {'operation': operation, 'token': result.token},
      );
    } catch (error) {
      if (AppConfig.playIntegrityRequired) {
        rethrow;
      }
    }
  }
}
