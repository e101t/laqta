import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:laqta/core/security/rasp/rasp_coordinator.dart';
import 'package:laqta/core/security/rasp/security_check_result.dart';
import 'package:laqta/features/payment/security/fraud_detector.dart';

void main() {
  test('source files contain no Stripe secret keys', () async {
    final offenders = <String>[];
    await for (final entity in Directory('lib').list(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final text = await entity.readAsString();
      final liveSecretPrefix = 'sk_${'live'}';
      final testSecretPrefix = 'sk_${'test'}';
      if (text.contains(liveSecretPrefix) || text.contains(testSecretPrefix)) {
        offenders.add(entity.path);
      }
    }
    expect(offenders, isEmpty);
  });

  test('payment is blocked on rooted mock', () {
    final status = SecurityStatus.fromSignals(const <SecuritySignal>[
      SecuritySignal(name: 'root_detected', detected: true),
    ]);

    final decision = FraudDetector().evaluate(
      itemId: 'booking-1',
      amount: 100,
      expectedAmount: 100,
      securityStatus: status,
    );

    expect(decision.allowed, isFalse);
  });

  test('payment is blocked on emulator mock', () {
    final status = SecurityStatus.fromSignals(const <SecuritySignal>[
      SecuritySignal(name: 'emulator_detected', detected: true),
    ]);

    final decision = FraudDetector().evaluate(
      itemId: 'booking-1',
      amount: 100,
      expectedAmount: 100,
      securityStatus: status,
    );

    expect(decision.allowed, isFalse);
  });
}
