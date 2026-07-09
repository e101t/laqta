import 'package:laqta/core/config/app_config.dart';
import 'package:laqta/core/localization/app_localizations.dart';
import 'package:laqta/features/auth/data/utils/phone_number_utils.dart';

class ValidationResult {
  const ValidationResult._(this.isValid, this.message);

  const ValidationResult.valid() : this._(true, null);

  const ValidationResult.invalid(String message) : this._(false, message);

  final bool isValid;
  final String? message;
}

class AppValidators {
  AppValidators._();

  static final RegExp _emailPattern = RegExp(
    r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
  );
  static final RegExp _namePattern = RegExp(r"^[\u0600-\u06FFA-Za-z\s'-]+$");
  static final RegExp _otpPattern = RegExp(r'^\d{6}$');

  static final RegExp _e164Pattern = RegExp(r'^\+[1-9]\d{7,14}$');

  static List<String> get _supportedPhonePrefixes => AppConfig
      .supportedPhonePrefixes
      .split(',')
      .map((prefix) => prefix.trim())
      .where((prefix) => prefix.isNotEmpty)
      .toList();

  /// E.164 phone validation limited to the markets enabled via
  /// `SUPPORTED_PHONE_PREFIXES` (defaults to Iraqi mobile numbers).
  static ValidationResult phone(String value) {
    final normalized = normalizePhoneNumberForOtp(value);
    final matchesMarket = _supportedPhonePrefixes.any(normalized.startsWith);
    if (_e164Pattern.hasMatch(normalized) && matchesMarket) {
      return const ValidationResult.valid();
    }
    return ValidationResult.invalid(AppLocalizations.current.invalidPhoneError);
  }

  static ValidationResult iraqiPhone(String value) => phone(value);

  static String normalizeIraqiPhone(String value) {
    return normalizePhoneNumberForOtp(value);
  }

  static ValidationResult email(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty || !_emailPattern.hasMatch(trimmed)) {
      return ValidationResult.invalid(AppLocalizations.current.emailInvalid);
    }
    return const ValidationResult.valid();
  }

  static ValidationResult requiredName(String value, {int maxLength = 60}) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return ValidationResult.invalid(AppLocalizations.current.nameRequired);
    }
    if (trimmed.length > maxLength) {
      return ValidationResult.invalid(AppLocalizations.current.nameTooLong);
    }
    if (!_namePattern.hasMatch(trimmed)) {
      return ValidationResult.invalid(
      AppLocalizations.current.nameInvalidChars,
    );
    }
    return const ValidationResult.valid();
  }

  static ValidationResult otp(String value) {
    if (_otpPattern.hasMatch(value.trim())) {
      return const ValidationResult.valid();
    }
    return ValidationResult.invalid(AppLocalizations.current.otpSixDigits);
  }

  static ValidationResult futureDate(DateTime value, {DateTime? now}) {
    final today = _dateOnly(now ?? DateTime.now());
    final target = _dateOnly(value);
    if (target.isAfter(today)) {
      return const ValidationResult.valid();
    }
    return ValidationResult.invalid(
      AppLocalizations.current.futureDateRequired,
    );
  }

  static ValidationResult adultBirthdate(DateTime value, {DateTime? now}) {
    final reference = now ?? DateTime.now();
    var age = reference.year - value.year;
    if (reference.month < value.month ||
        (reference.month == value.month && reference.day < value.day)) {
      age--;
    }
    if (age >= 18) {
      return const ValidationResult.valid();
    }
    return ValidationResult.invalid(AppLocalizations.current.mustBeAdult);
  }

  static DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }
}
