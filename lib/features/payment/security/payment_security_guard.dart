import 'package:flutter/material.dart';
import 'package:laqta/core/auth/biometric/biometric_guard.dart';
import 'package:laqta/core/auth/device/device_binder.dart';
import 'package:laqta/core/network/signing/request_signer.dart';
import 'package:laqta/core/security/integrity_checker.dart';
import 'package:laqta/core/security/monitoring/security_event_logger.dart';
import 'package:laqta/core/security/rasp/rasp_coordinator.dart';
import 'package:laqta/features/payment/security/fraud_detector.dart';

class PaymentSecurityGuard {
  PaymentSecurityGuard({
    RaspCoordinator? raspCoordinator,
    IntegrityChecker? integrityChecker,
    BiometricGuard? biometricGuard,
    DeviceBinder? deviceBinder,
    FraudDetector? fraudDetector,
    SecurityEventLogger? logger,
  }) : _raspCoordinator = raspCoordinator ?? RaspCoordinator.instance,
       _integrityChecker = integrityChecker ?? IntegrityChecker.instance,
       _biometricGuard = biometricGuard ?? BiometricGuard.instance,
       _deviceBinder = deviceBinder ?? DeviceBinder.instance,
       _fraudDetector = fraudDetector ?? FraudDetector.instance,
       _logger = logger ?? SecurityEventLogger.instance;

  static final PaymentSecurityGuard instance = PaymentSecurityGuard();

  final RaspCoordinator _raspCoordinator;
  final IntegrityChecker _integrityChecker;
  final BiometricGuard _biometricGuard;
  final DeviceBinder _deviceBinder;
  final FraudDetector _fraudDetector;
  final SecurityEventLogger _logger;

  Future<PaymentSecurityResult> authorizePayment({
    required BuildContext context,
    required String itemId,
    required double amount,
    required String payeeName,
  }) async {
    final status = await _raspCoordinator.runAllChecks(logoutOnCritical: true);
    if (_raspCoordinator.decisionFor(
          SecurityFeature.payments,
          status: status,
        ) ==
        FeatureGateDecision.block) {
      await _logger.log(
        'payment_blocked',
        severity: 'critical',
        details: status.toJson(),
      );
      return PaymentSecurityResult.blocked(status.userMessage);
    }

    final fraud = _fraudDetector.evaluate(
      itemId: itemId,
      amount: amount,
      expectedAmount: amount,
      securityStatus: status,
    );
    if (!fraud.allowed) {
      await _logger.log(
        'payment_blocked',
        severity: 'warning',
        details: fraud.toJson(),
      );
      return PaymentSecurityResult.blocked(fraud.reason);
    }

    final biometricOk = await _biometricGuard.authenticate(
      reason: 'يرجى تأكيد هويتك لإتمام الدفع',
    );
    if (!biometricOk) {
      return const PaymentSecurityResult.blocked('تعذر تأكيد الهوية.');
    }

    await _integrityChecker.verifyForOperation('payment');
    final deviceId = await _deviceBinder.deviceId();
    final nonce = generateNonce();
    final confirmed = context.mounted
        ? await _confirmPayment(context, amount: amount, payeeName: payeeName)
        : false;
    if (!confirmed) {
      return const PaymentSecurityResult.blocked('تم إلغاء الدفع.');
    }

    return PaymentSecurityResult.allowed(
      PaymentSecurityContext(deviceId: deviceId, nonce: nonce),
    );
  }

  Future<bool> _confirmPayment(
    BuildContext context, {
    required double amount,
    required String payeeName,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('تأكيد الدفع'),
            content: Text(
              'أنت على وشك دفع ${amount.toStringAsFixed(0)} لـ $payeeName',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('إلغاء'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('تأكيد'),
              ),
            ],
          ),
        ) ??
        false;
  }
}

class PaymentSecurityResult {
  const PaymentSecurityResult._({
    required this.allowed,
    this.reason,
    this.context,
  });

  const PaymentSecurityResult.allowed(PaymentSecurityContext context)
    : this._(allowed: true, context: context);

  const PaymentSecurityResult.blocked(String reason)
    : this._(allowed: false, reason: reason);

  final bool allowed;
  final String? reason;
  final PaymentSecurityContext? context;
}

class PaymentSecurityContext {
  const PaymentSecurityContext({required this.deviceId, required this.nonce});

  final String deviceId;
  final String nonce;
}
