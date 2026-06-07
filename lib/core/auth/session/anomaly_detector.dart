import 'dart:collection';

class SessionAnomalyDetector {
  SessionAnomalyDetector({DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  static final SessionAnomalyDetector instance = SessionAnomalyDetector();

  final DateTime Function() _clock;
  final Queue<DateTime> _requestTimes = Queue<DateTime>();
  DateTime? _backgroundedAt;

  void markBackgrounded() {
    _backgroundedAt = _clock();
  }

  bool consumeNeedsReauthAfterLongBackground() {
    final backgroundedAt = _backgroundedAt;
    _backgroundedAt = null;
    if (backgroundedAt == null) {
      return false;
    }
    return _clock().difference(backgroundedAt) > const Duration(minutes: 30);
  }

  bool recordRequestAndDetectBurst() {
    final now = _clock();
    _requestTimes.addLast(now);
    while (_requestTimes.isNotEmpty &&
        now.difference(_requestTimes.first) > const Duration(seconds: 10)) {
      _requestTimes.removeFirst();
    }
    return _requestTimes.length > 20;
  }

  bool isSessionRevokedHeader(Map<String, String> headers) {
    final value = headers['x-session-revoked'] ?? headers['X-Session-Revoked'];
    return value != null && value.toLowerCase() == 'true';
  }
}
