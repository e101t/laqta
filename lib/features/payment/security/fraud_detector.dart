import 'package:laqta/core/security/rasp/rasp_coordinator.dart';

class FraudDetector {
  FraudDetector({DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  static final FraudDetector instance = FraudDetector();

  final DateTime Function() _clock;
  final Map<String, List<DateTime>> _paymentsByItem =
      <String, List<DateTime>>{};

  FraudDecision evaluate({
    required String itemId,
    required double amount,
    required double expectedAmount,
    required SecurityStatus securityStatus,
  }) {
    if (amount <= 0 || (amount - expectedAmount).abs() > 0.01) {
      return const FraudDecision.blocked(
        'تم إيقاف الدفع بسبب اختلاف مبلغ العملية.',
      );
    }
    if (securityStatus.isEmulator) {
      return const FraudDecision.blocked(
        'لا يمكن تنفيذ الدفع من بيئة غير موثوقة.',
      );
    }
    if (securityStatus.isRooted) {
      return const FraudDecision.blocked(
        'تم إيقاف الدفع على جهاز معدّل لحماية حسابك.',
      );
    }

    final now = _clock();
    final windowStart = now.subtract(const Duration(hours: 1));
    final attempts = _paymentsByItem.putIfAbsent(itemId, () => <DateTime>[]);
    attempts.removeWhere((attempt) => attempt.isBefore(windowStart));
    if (attempts.length >= 3) {
      return const FraudDecision.blocked(
        'يرجى إعادة تسجيل الدخول قبل تكرار هذه العملية.',
      );
    }
    attempts.add(now);
    return const FraudDecision.allowed();
  }
}

class FraudDecision {
  const FraudDecision._({required this.allowed, required this.reason});

  const FraudDecision.allowed() : this._(allowed: true, reason: '');

  const FraudDecision.blocked(String reason)
    : this._(allowed: false, reason: reason);

  final bool allowed;
  final String reason;

  Map<String, Object?> toJson() {
    return <String, Object?>{'allowed': allowed, 'reason': reason};
  }
}
