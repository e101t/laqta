import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:laqta/core/services/backend_config.dart';

enum NetworkReachability { online, offline, degraded }

class ConnectivityStateSnapshot {
  const ConnectivityStateSnapshot({
    required this.reachability,
    required this.results,
    required this.checkedAt,
    this.lastOnlineAt,
  });

  final NetworkReachability reachability;
  final List<ConnectivityResult> results;
  final DateTime checkedAt;
  final DateTime? lastOnlineAt;

  bool get isOnline => reachability == NetworkReachability.online;
  bool get isOffline => reachability == NetworkReachability.offline;
  bool get isDegraded => reachability == NetworkReachability.degraded;
}

class ConnectivityService {
  ConnectivityService({Connectivity? connectivity, http.Client? client})
    : _connectivity = connectivity ?? Connectivity(),
      _client = client ?? http.Client();

  final Connectivity _connectivity;
  final http.Client _client;
  final StreamController<ConnectivityStateSnapshot> _controller =
      StreamController<ConnectivityStateSnapshot>.broadcast();

  StreamSubscription<List<ConnectivityResult>>? _subscription;
  ConnectivityStateSnapshot? _latest;
  DateTime? _lastOnlineAt;

  Stream<ConnectivityStateSnapshot> get stream => _controller.stream;
  ConnectivityStateSnapshot? get latest => _latest;

  Future<void> start() async {
    if (_subscription != null) return;
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      unawaited(_check(results));
    });
    await _check(await _connectivity.checkConnectivity());
  }

  Future<ConnectivityStateSnapshot> checkNow() async {
    return _check(await _connectivity.checkConnectivity());
  }

  Future<ConnectivityStateSnapshot> _check(
    List<ConnectivityResult> results,
  ) async {
    final normalized = results.isEmpty
        ? <ConnectivityResult>[ConnectivityResult.none]
        : results;
    var reachability = normalized.contains(ConnectivityResult.none)
        ? NetworkReachability.offline
        : NetworkReachability.online;

    if (reachability == NetworkReachability.online) {
      final backendReachable = await _pingBackend();
      if (backendReachable) {
        _lastOnlineAt = DateTime.now();
      } else {
        reachability = NetworkReachability.degraded;
      }
    }

    final snapshot = ConnectivityStateSnapshot(
      reachability: reachability,
      results: normalized,
      checkedAt: DateTime.now(),
      lastOnlineAt: _lastOnlineAt,
    );
    _latest = snapshot;
    _controller.add(snapshot);
    return snapshot;
  }

  Future<bool> _pingBackend() async {
    try {
      final response = await _client
          .get(BackendConfig.apiUri('/health'))
          .timeout(const Duration(seconds: 3));
      return response.statusCode >= 200 && response.statusCode < 500;
    } catch (_) {
      return false;
    }
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    await _controller.close();
    _client.close();
  }
}
