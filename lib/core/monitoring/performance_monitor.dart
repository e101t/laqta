import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;

/// أداة قياس الأداء والـ Frame Rate في التطبيق
class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._();

  factory PerformanceMonitor() => _instance;

  PerformanceMonitor._();

  final List<PerformanceMetric> _metrics = [];
  late WidgetsBinding _binding;
  Timer? _fpsTimer;
  int _frameCount = 0;
  double _fps = 60.0;

  void initialize() {
    _binding = WidgetsBinding.instance;
    _binding.addObserver(this);
    _startFpsMonitoring();
  }

  /// قياس وقت تنفيذ عملية
  Future<T> measureAsync<T>(
    String name,
    Future<T> Function() operation, {
    Duration warningThreshold = const Duration(milliseconds: 100),
  }) async {
    final stopwatch = Stopwatch()..start();

    try {
      final result = await operation();
      stopwatch.stop();

      _recordMetric(
        name,
        stopwatch.elapsed,
        warningThreshold,
      );

      return result;
    } catch (e) {
      stopwatch.stop();
      _recordMetric(
        '$name (ERROR)',
        stopwatch.elapsed,
        warningThreshold,
        isError: true,
      );
      rethrow;
    }
  }

  /// قياس عملية متزامنة
  T measureSync<T>(
    String name,
    T Function() operation, {
    Duration warningThreshold = const Duration(milliseconds: 16),
  }) {
    final stopwatch = Stopwatch()..start();

    try {
      final result = operation();
      stopwatch.stop();

      _recordMetric(
        name,
        stopwatch.elapsed,
        warningThreshold,
      );

      return result;
    } catch (e) {
      stopwatch.stop();
      _recordMetric(
        '$name (ERROR)',
        stopwatch.elapsed,
        warningThreshold,
        isError: true,
      );
      rethrow;
    }
  }

  void _recordMetric(
    String name,
    Duration duration,
    Duration warningThreshold, {
    bool isError = false,
  }) {
    final metric = PerformanceMetric(
      name: name,
      duration: duration,
      timestamp: DateTime.now(),
      isError: isError,
      exceededThreshold: duration > warningThreshold,
    );

    _metrics.add(metric);

    // تحذير إذا تجاوز الـ threshold
    if (metric.exceededThreshold) {
      debugPrint(
        '⚠️ PERF WARNING: $name took ${duration.inMilliseconds}ms '
        '(threshold: ${warningThreshold.inMilliseconds}ms)',
      );
    }

    // احفظ فقط آخر 1000 metric
    if (_metrics.length > 1000) {
      _metrics.removeAt(0);
    }
  }

  void _startFpsMonitoring() {
    _fpsTimer = Timer.periodic(Duration(seconds: 1), (_) {
      _fps = _frameCount.toDouble();
      _frameCount = 0;

      if (_fps < 50) {
        debugPrint('🔴 LOW FPS: $_fps FPS');
      } else if (_fps < 60) {
        debugPrint('🟡 DROPPING FPS: $_fps FPS');
      }
    });

    _binding.window.onReportTimings = (timings) {
      for (final timing in timings) {
        if (timing.vsyncOverhead > Duration.zero) {
          _frameCount++;
        }
      }
    };
  }

  /// الحصول على تقرير الأداء
  String getReport() {
    if (_metrics.isEmpty) return 'No metrics recorded';

    final buffer = StringBuffer();
    buffer.writeln('═══ PERFORMANCE REPORT ═══');
    buffer.writeln('Total Metrics: ${_metrics.length}');
    buffer.writeln('Average FPS: ${_fps.toStringAsFixed(1)}');
    buffer.writeln('');

    // تجميع حسب الاسم
    final grouped = <String, List<PerformanceMetric>>{};
    for (final metric in _metrics) {
      grouped.putIfAbsent(metric.name, () => []).add(metric);
    }

    // عرض المتوسطات
    for (final entry in grouped.entries) {
      final metrics = entry.value;
      final avgDuration = metrics.fold<Duration>(
        Duration.zero,
        (sum, m) => sum + m.duration,
      ) ~/ metrics.length;

      final icon = metrics.any((m) => m.exceededThreshold) ? '⚠️' : '✅';

      buffer.writeln('$icon ${entry.key}');
      buffer.writeln('  Avg: ${avgDuration.inMilliseconds}ms');
      buffer.writeln('  Min: ${metrics.map((m) => m.duration.inMilliseconds).reduce((a, b) => a < b ? a : b)}ms');
      buffer.writeln('  Max: ${metrics.map((m) => m.duration.inMilliseconds).reduce((a, b) => a > b ? a : b)}ms');
      buffer.writeln('');
    }

    return buffer.toString();
  }

  /// الحصول على آخر الـ metrics
  List<PerformanceMetric> getLatestMetrics({int limit = 50}) {
    return _metrics.skip((_metrics.length - limit).clamp(0, _metrics.length)).toList();
  }

  void clear() => _metrics.clear();

  void dispose() {
    _fpsTimer?.cancel();
  }
}

class PerformanceMetric {
  final String name;
  final Duration duration;
  final DateTime timestamp;
  final bool isError;
  final bool exceededThreshold;

  PerformanceMetric({
    required this.name,
    required this.duration,
    required this.timestamp,
    required this.isError,
    required this.exceededThreshold,
  });

  @override
  String toString() =>
    '$name: ${duration.inMilliseconds}ms (${timestamp.toString()})';
}

/// Debouncer للعمليات المتكررة
class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  void dispose() => _timer?.cancel();
}

/// CacheManager للـ performance
class CacheManager {
  static final CacheManager _instance = CacheManager._();
  final Map<String, CachedValue> _cache = {};

  factory CacheManager() => _instance;
  CacheManager._();

  T? get<T>(String key) {
    final value = _cache[key];
    if (value != null && !value.isExpired) {
      return value.value as T?;
    }
    return null;
  }

  void set<T>(String key, T value, {Duration ttl = const Duration(hours: 1)}) {
    _cache[key] = CachedValue(
      value: value,
      expiredAt: DateTime.now().add(ttl),
    );
  }

  void clear() => _cache.clear();
}

class CachedValue {
  final dynamic value;
  final DateTime expiredAt;

  CachedValue({required this.value, required this.expiredAt});

  bool get isExpired => DateTime.now().isAfter(expiredAt);
}
