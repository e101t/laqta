import 'package:flutter_test/flutter_test.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:laqta/core/network/connectivity/connectivity_service.dart';
import 'package:laqta/core/network/connectivity/request_queue.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'request queue stores non-payment writes and rejects payment retries',
    () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final queue = RequestQueue(
        preferences: await SharedPreferences.getInstance(),
      );

      final queued = await queue.enqueue(
        QueuedWriteRequest(
          method: 'POST',
          path: '/profile',
          headers: const <String, String>{'content-type': 'application/json'},
          body: '{}',
          createdAtMs: 1,
        ),
      );
      final paymentQueued = await queue.enqueue(
        QueuedWriteRequest(
          method: 'POST',
          path: '/payments/intents',
          headers: const <String, String>{},
          body: '{}',
          createdAtMs: 2,
        ),
      );

      expect(queued, isTrue);
      expect(paymentQueued, isFalse);
      expect(await queue.pendingCount(), 1);
    },
  );

  test('connectivity snapshot exposes state helpers', () {
    final snapshot = ConnectivityStateSnapshot(
      reachability: NetworkReachability.degraded,
      results: const <ConnectivityResult>[],
      checkedAt: DateTime.fromMillisecondsSinceEpoch(0),
    );

    expect(snapshot.isDegraded, isTrue);
    expect(snapshot.isOnline, isFalse);
    expect(snapshot.isOffline, isFalse);
  });
}
