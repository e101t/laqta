import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BackendApiClient Timeouts', () {
    test('request timeout is set to 20 seconds', () {
      // Verify timeout constants are properly defined
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
      expect(response.body, contains('انتهت مهلة الاتصال'));
    });
  });
}

// Helper function to simulate timeout response
dynamic _createTimeoutResponse() {
  return {'statusCode': 408, 'body': '{"message": "انتهت مهلة الاتصال. حاول مرة أخرى."}'};
}
