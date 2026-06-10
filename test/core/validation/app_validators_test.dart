import 'package:flutter_test/flutter_test.dart';
import 'package:laqta/core/validation/app_validators.dart';

void main() {
  group('AppValidators.iraqiPhone', () {
    test('accepts local Iraqi mobile numbers', () {
      final result = AppValidators.iraqiPhone('07721700800');

      expect(result.isValid, isTrue);
      expect(
        AppValidators.normalizeIraqiPhone('07721700800'),
        '+9647721700800',
      );
    });

    test('accepts Arabic numerals', () {
      final result = AppValidators.iraqiPhone('٠٧٧٢١٧٠٠٨٠٠');

      expect(result.isValid, isTrue);
    });

    test('rejects invalid mobile numbers', () {
      final result = AppValidators.iraqiPhone('12345');

      expect(result.isValid, isFalse);
      expect(result.message, 'رقم الهاتف غير صحيح');
    });
  });

  group('AppValidators.email', () {
    test('accepts valid email', () {
      expect(AppValidators.email('user@example.com').isValid, isTrue);
    });

    test('rejects invalid email', () {
      expect(AppValidators.email('not-email').isValid, isFalse);
    });
  });

  group('AppValidators.requiredName', () {
    test('accepts Arabic names', () {
      expect(AppValidators.requiredName('علي حسن').isValid, isTrue);
    });

    test('rejects symbols', () {
      expect(AppValidators.requiredName('Ali <script>').isValid, isFalse);
    });
  });

  group('AppValidators.otp', () {
    test('accepts exactly 6 digits', () {
      expect(AppValidators.otp('123456').isValid, isTrue);
    });

    test('rejects non 6 digit codes', () {
      expect(AppValidators.otp('12345a').isValid, isFalse);
    });
  });

  group('AppValidators.futureDate', () {
    test('accepts future dates', () {
      final now = DateTime(2026, 6, 5);

      expect(
        AppValidators.futureDate(DateTime(2026, 6, 6), now: now).isValid,
        isTrue,
      );
    });

    test('rejects today and past dates', () {
      final now = DateTime(2026, 6, 5);

      expect(
        AppValidators.futureDate(DateTime(2026, 6, 5), now: now).isValid,
        isFalse,
      );
      expect(
        AppValidators.futureDate(DateTime(2026, 6, 4), now: now).isValid,
        isFalse,
      );
    });
  });

  group('AppValidators.adultBirthdate', () {
    test('accepts 18 plus users', () {
      final now = DateTime(2026, 6, 5);

      expect(
        AppValidators.adultBirthdate(DateTime(2008, 6, 5), now: now).isValid,
        isTrue,
      );
    });

    test('rejects underage users', () {
      final now = DateTime(2026, 6, 5);

      expect(
        AppValidators.adultBirthdate(DateTime(2008, 6, 6), now: now).isValid,
        isFalse,
      );
    });
  });
}
