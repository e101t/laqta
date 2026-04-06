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

    test('accepts Arabic numerals from Iraqi keyboards', () {
      expect(
        normalizePhoneNumberForFirebase('٠٧٧٢١٧٠٠٨٠٠'),
        '+9647721700800',
      );
    });
  });

  group('normalizePhoneNumberForLocalInput', () {
    test('keeps local Iraqi number without country code', () {
      expect(normalizePhoneNumberForLocalInput('07721700800'), '07721700800');
    });

    test('converts international Iraqi number to local display format', () {
      expect(
        normalizePhoneNumberForLocalInput('+964 772 170 0800'),
        '07721700800',
      );
    });

    test('converts Arabic numerals to local ASCII digits', () {
      expect(normalizePhoneNumberForLocalInput('٠٧٧٢١٧٠٠٨٠٠'), '07721700800');
    });
  });
}
