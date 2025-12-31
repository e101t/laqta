import 'dart:async';
import 'package:flutter/foundation.dart';

/// Debouncer for optimizing search and other frequent operations
class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({required this.delay});

  void call(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void dispose() {
    _timer?.cancel();
  }
}

/// Throttler for limiting function calls
class Throttler {
  final Duration duration;
  DateTime? _lastActionTime;

  Throttler({required this.duration});

  void call(VoidCallback action) {
    final now = DateTime.now();
    if (_lastActionTime == null ||
        now.difference(_lastActionTime!) >= duration) {
      _lastActionTime = now;
      action();
    }
  }
}
