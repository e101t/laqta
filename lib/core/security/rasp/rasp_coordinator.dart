import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:laqta/core/auth/token_manager.dart';
import 'package:laqta/core/security/monitoring/security_event_logger.dart';
import 'package:laqta/core/security/rasp/debugger_detector.dart';
import 'package:laqta/core/security/rasp/emulator_detector.dart';
import 'package:laqta/core/security/rasp/hook_detector.dart';
import 'package:laqta/core/security/rasp/integrity_verifier.dart';
import 'package:laqta/core/security/rasp/root_detector.dart';
import 'package:laqta/core/security/rasp/security_check_result.dart';

class RaspCoordinator {
  RaspCoordinator({
    RootDetector? rootDetector,
    EmulatorDetector? emulatorDetector,
    HookDetector? hookDetector,
    DebuggerDetector? debuggerDetector,
    IntegrityVerifier? integrityVerifier,
    SecurityEventLogger? logger,
    TokenManager? tokenManager,
  }) : _rootDetector = rootDetector ?? RootDetector(),
       _emulatorDetector = emulatorDetector ?? EmulatorDetector(),
       _hookDetector = hookDetector ?? HookDetector(),
       _debuggerDetector = debuggerDetector ?? DebuggerDetector(),
       _integrityVerifier = integrityVerifier ?? IntegrityVerifier(),
       _logger = logger ?? SecurityEventLogger.instance,
       _tokenManager = tokenManager ?? TokenManager();

  static final RaspCoordinator instance = RaspCoordinator();
  static final ValueNotifier<SecurityStatus?> latestStatus =
      ValueNotifier<SecurityStatus?>(null);

  final RootDetector _rootDetector;
  final EmulatorDetector _emulatorDetector;
  final HookDetector _hookDetector;
  final DebuggerDetector _debuggerDetector;
  final IntegrityVerifier _integrityVerifier;
  final SecurityEventLogger _logger;
  final TokenManager _tokenManager;

  Future<SecurityStatus> runAllChecks({bool logoutOnCritical = false}) async {
    final results =
        await Future.wait<SecuritySignal>([
          _rootDetector.check(),
          _emulatorDetector.check(),
          _hookDetector.check(),
          _debuggerDetector.check(),
          _integrityVerifier.check(),
        ]).timeout(
          const Duration(seconds: 6),
          onTimeout: () {
            return const <SecuritySignal>[
              SecuritySignal(
                name: 'rasp_timeout',
                detected: true,
                severity: SecuritySeverity.warning,
              ),
            ];
          },
        );

    final status = SecurityStatus.fromSignals(results);
    latestStatus.value = status;

    for (final signal in results) {
      if (signal.detected) {
        await _logger.log(
          signal.name,
          severity: signal.severity.name,
          details: signal.toJson(),
        );
      }
    }

    if (logoutOnCritical && status.requiresImmediateLogout) {
      await _tokenManager.clearAllTokens();
      await _logger.log(
        status.isHooked ? 'hook_detected' : 'debugger_or_tamper_detected',
        severity: 'critical',
        details: status.toJson(),
      );
    }

    return status;
  }

  FeatureGateDecision decisionFor(
    SecurityFeature feature, {
    SecurityStatus? status,
  }) {
    final current = status ?? latestStatus.value ?? SecurityStatus.clean;
    if (current.isTampered) {
      return FeatureGateDecision.block;
    }
    if (current.isHooked || current.isDebugged) {
      return feature == SecurityFeature.explore
          ? FeatureGateDecision.warn
          : FeatureGateDecision.block;
    }
    if (current.isEmulator && kReleaseMode) {
      return feature == SecurityFeature.explore
          ? FeatureGateDecision.allow
          : FeatureGateDecision.block;
    }
    if (current.isRooted) {
      switch (feature) {
        case SecurityFeature.payments:
          return FeatureGateDecision.block;
        case SecurityFeature.uploadMedia:
        case SecurityFeature.auth:
        case SecurityFeature.chat:
          return FeatureGateDecision.warn;
        case SecurityFeature.explore:
          return FeatureGateDecision.allow;
      }
    }
    return FeatureGateDecision.allow;
  }

  bool isAllowed(SecurityFeature feature, {SecurityStatus? status}) {
    return decisionFor(feature, status: status) != FeatureGateDecision.block;
  }
}

enum SecurityFeature { auth, payments, uploadMedia, explore, chat }

enum FeatureGateDecision { allow, warn, block }

class SecurityStatus {
  const SecurityStatus({
    required this.root,
    required this.emulator,
    required this.hook,
    required this.debugger,
    required this.integrity,
  });

  static const clean = SecurityStatus(
    root: SecuritySignal(name: 'root_detected', detected: false),
    emulator: SecuritySignal(name: 'emulator_detected', detected: false),
    hook: SecuritySignal(name: 'hook_detected', detected: false),
    debugger: SecuritySignal(name: 'debugger_detected', detected: false),
    integrity: SecuritySignal(name: 'tampered_apk', detected: false),
  );

  final SecuritySignal root;
  final SecuritySignal emulator;
  final SecuritySignal hook;
  final SecuritySignal debugger;
  final SecuritySignal integrity;

  bool get isRooted => root.detected;
  bool get isEmulator => emulator.detected;
  bool get isHooked => hook.detected;
  bool get isDebugged => debugger.detected;
  bool get isTampered => integrity.detected;
  bool get isClean =>
      !isRooted && !isEmulator && !isHooked && !isDebugged && !isTampered;
  bool get requiresImmediateLogout => isHooked || isDebugged || isTampered;

  String get userMessage {
    if (isHooked || isDebugged) {
      return 'تم اكتشاف تدخل غير مشروع. تم تسجيل خروجك لحماية حسابك.';
    }
    if (isTampered) {
      return 'تعذر التحقق من سلامة التطبيق. يرجى تثبيت النسخة الرسمية.';
    }
    if (isRooted) {
      return 'تم اكتشاف جهاز معدّل. بعض الميزات معطّلة لحماية بياناتك.';
    }
    if (isEmulator) {
      return 'لا يمكن استخدام الميزات الحساسة من بيئة غير موثوقة.';
    }
    return '';
  }

  static SecurityStatus fromSignals(List<SecuritySignal> signals) {
    SecuritySignal find(String name) => signals.firstWhere(
      (signal) => signal.name == name,
      orElse: () => SecuritySignal(name: name, detected: false),
    );
    return SecurityStatus(
      root: find('root_detected'),
      emulator: find('emulator_detected'),
      hook: find('hook_detected'),
      debugger: find('debugger_detected'),
      integrity: find('tampered_apk'),
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'root': root.toJson(),
      'emulator': emulator.toJson(),
      'hook': hook.toJson(),
      'debugger': debugger.toJson(),
      'integrity': integrity.toJson(),
      'is_clean': isClean,
    };
  }
}
