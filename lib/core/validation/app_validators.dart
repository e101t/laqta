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

  static ValidationResult iraqiPhone(String value) {
    final normalized = normalizePhoneNumberForOtp(value);
    if (RegExp(r'^\+9647\d{9}$').hasMatch(normalized)) {
      return const ValidationResult.valid();
    }
    return const ValidationResult.invalid('رقم الهاتف غير صحيح');
  }

  static String normalizeIraqiPhone(String value) {
    return normalizePhoneNumberForOtp(value);
  }

  static ValidationResult email(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty || !_emailPattern.hasMatch(trimmed)) {
      return const ValidationResult.invalid('البريد الإلكتروني غير صحيح');
    }
    return const ValidationResult.valid();
  }

  static ValidationResult requiredName(String value, {int maxLength = 60}) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return const ValidationResult.invalid('الاسم مطلوب');
    }
    if (trimmed.length > maxLength) {
      return const ValidationResult.invalid('الاسم طويل جداً');
    }
    if (!_namePattern.hasMatch(trimmed)) {
      return const ValidationResult.invalid('الاسم يحتوي على أحرف غير مسموحة');
    }
    return const ValidationResult.valid();
  }

  static ValidationResult otp(String value) {
    if (_otpPattern.hasMatch(value.trim())) {
      return const ValidationResult.valid();
    }
    return const ValidationResult.invalid('أدخل رمز تحقق مكون من 6 أرقام');
  }

  static ValidationResult futureDate(DateTime value, {DateTime? now}) {
    final today = _dateOnly(now ?? DateTime.now());
    final target = _dateOnly(value);
    if (target.isAfter(today)) {
      return const ValidationResult.valid();
    }
    return const ValidationResult.invalid('يجب اختيار تاريخ مستقبلي');
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
    return const ValidationResult.invalid('يجب أن يكون العمر 18 سنة أو أكثر');
  }

  static DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }
}
