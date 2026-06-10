import 'package:flutter_test/flutter_test.dart';
import 'package:laqta/core/security/rasp/rasp_coordinator.dart';
import 'package:laqta/core/security/rasp/security_check_result.dart';

void main() {
  test('rooted status blocks payments and warns uploads', () {
    final status = SecurityStatus.fromSignals(const <SecuritySignal>[
      SecuritySignal(name: 'root_detected', detected: true, vectorCount: 2),
    ]);
    final coordinator = RaspCoordinator.instance;

    expect(
      coordinator.decisionFor(SecurityFeature.payments, status: status),
      FeatureGateDecision.block,
    );
    expect(
      coordinator.decisionFor(SecurityFeature.uploadMedia, status: status),
      FeatureGateDecision.warn,
    );
  });

  test('hooked status blocks protected features', () {
    final status = SecurityStatus.fromSignals(const <SecuritySignal>[
      SecuritySignal(name: 'hook_detected', detected: true),
    ]);
    final coordinator = RaspCoordinator.instance;

    expect(status.requiresImmediateLogout, isTrue);
    expect(
      coordinator.decisionFor(SecurityFeature.chat, status: status),
      FeatureGateDecision.block,
    );
  });

  test('tampered apk blocks all features quickly', () {
    final stopwatch = Stopwatch()..start();
    final status = SecurityStatus.fromSignals(const <SecuritySignal>[
      SecuritySignal(name: 'tampered_apk', detected: true),
    ]);
    final decision = RaspCoordinator.instance.decisionFor(
      SecurityFeature.explore,
      status: status,
    );
    stopwatch.stop();

    expect(decision, FeatureGateDecision.block);
    expect(stopwatch.elapsedMilliseconds, lessThan(500));
  });
}
