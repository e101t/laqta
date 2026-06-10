import 'dart:async';
import 'package:laqta/core/logging/app_logger.dart';

import 'package:flutter/foundation.dart';
import 'package:laqta/core/auth/token_manager.dart';
import 'package:laqta/core/network/pinning/certificate_pinner.dart';
import 'package:laqta/core/security/monitoring/security_event_logger.dart';
import 'package:laqta/core/security/rasp/rasp_coordinator.dart';

class SecurityHealth {
  SecurityHealth({
    RaspCoordinator? raspCoordinator,
    CertificatePinner? certificatePinner,
    SecurityEventLogger? logger,
    TokenManager? tokenManager,
  }) : _raspCoordinator = raspCoordinator ?? RaspCoordinator(),
       _certificatePinner = certificatePinner ?? CertificatePinner(),
       _logger = logger ?? SecurityEventLogger.instance,
       _tokenManager = tokenManager ?? TokenManager();

  static final SecurityHealth instance = SecurityHealth();

  final RaspCoordinator _raspCoordinator;
  final CertificatePinner _certificatePinner;
  final SecurityEventLogger _logger;
  final TokenManager _tokenManager;
  Timer? _timer;

  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(minutes: 10), (_) {
      unawaited(runOnce());
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> runOnce() async {
    try {
      final status = await _raspCoordinator.runAllChecks();
      await _certificatePinner.refreshRotatedPins();
      await _tokenManager.shouldRefreshAccessToken();
      await _logger.log(
        'security_health',
        severity: status.isClean ? 'info' : 'warning',
        details: status.toJson(),
      );
    } catch (error) {
      if (kDebugMode) {
        AppLogger.d('runtime', 'Security health check failed: $error');
      }
    }
  }
}

