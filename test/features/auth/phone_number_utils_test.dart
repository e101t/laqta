import 'package:flutter_test/flutter_test.dart';
import 'package:laqta/features/auth/data/utils/phone_number_utils.dart';

void main() {
  group('normalizePhoneNumberForFirebase', () {
    test('converts Iraqi local mobile numbers to E.164', () {
      expect(
        normalizePhoneNumberForFirebase('07721700800'),
        '+9647721700800',
      );
    });

    test('accepts Iraqi mobile numbers without leading zero', () {
      expect(
        normalizePhoneNumberForFirebase('7721700800'),
        '+9647721700800',
      );
    });

    test('keeps valid international numbers normalized', () {
      expect(
        normalizePhoneNumberForFirebase('+964 772 170 0800'),
        '+9647721700800',
      );
    });
  });
}
