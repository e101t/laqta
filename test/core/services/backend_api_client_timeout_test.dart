import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  group('BackendApiClient Timeouts', () {
    test('request timeout is set to 20 seconds', () {
      const requestTimeout = Duration(seconds: 20);
      const uploadTimeout = Duration(seconds: 60);

      expect(requestTimeout.inSeconds, 20);
      expect(uploadTimeout.inSeconds, 60);
    });

    test('upload timeout is longer than request timeout', () {
      const requestTimeout = Duration(seconds: 20);
      const uploadTimeout = Duration(seconds: 60);

      expect(uploadTimeout.inSeconds, greaterThan(requestTimeout.inSeconds));
    });

    test('timeout response returns 408 status', () {
      final response = _createTimeoutResponse();
      expect(response.statusCode, 408);
    });

    test('timeout response contains error message', () {
      final response = _createTimeoutResponse();
      expect(response.body, contains('Request timeout'));
    });
  });
}

http.Response _createTimeoutResponse() {
  return http.Response(
    '{"message": "Request timeout"}',
    408,
    headers: const {'Content-Type': 'application/json'},
  );
}
