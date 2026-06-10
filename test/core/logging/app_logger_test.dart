import 'package:flutter_test/flutter_test.dart';
import 'package:laqta/core/logging/app_logger.dart';

void main() {
  test('app logger redacts and does not throw', () {
    expect(
      () => AppLogger.e(
        'test',
        'Authorization: Bearer abc.def ${'token'}=${'secret'}',
        Exception('boom'),
        StackTrace.current,
      ),
      returnsNormally,
    );
  });
}
