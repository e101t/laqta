String _normalizeNumerals(String value) {
  const arabicIndic = {
    '٠': '0',
    '١': '1',
    '٢': '2',
    '٣': '3',
    '٤': '4',
    '٥': '5',
    '٦': '6',
    '٧': '7',
    '٨': '8',
    '٩': '9',
    '۰': '0',
    '۱': '1',
    '۲': '2',
    '۳': '3',
    '۴': '4',
    '۵': '5',
    '۶': '6',
    '۷': '7',
    '۸': '8',
    '۹': '9',
  };

  return value.split('').map((char) => arabicIndic[char] ?? char).join();
}

String normalizePhoneNumberForLocalInput(String rawPhoneNumber) {
  final normalizedDigits = _normalizeNumerals(
    rawPhoneNumber,
  ).replaceAll(RegExp(r'[^0-9]'), '');

  if (normalizedDigits.isEmpty) {
    return '';
  }

  String localNumber;
  if (normalizedDigits.startsWith('964') && normalizedDigits.length >= 12) {
    localNumber = '0${normalizedDigits.substring(3)}';
  } else if (normalizedDigits.startsWith('7') &&
      normalizedDigits.length >= 10) {
    localNumber = '0$normalizedDigits';
  } else {
    localNumber = normalizedDigits;
  }

  return localNumber.substring(0, localNumber.length.clamp(0, 11));
}

String normalizePhoneNumberForFirebase(String rawPhoneNumber) {
  final trimmed = _normalizeNumerals(rawPhoneNumber.trim());
  if (trimmed.isEmpty) {
    return trimmed;
  }

  final normalized = trimmed.replaceAll(RegExp(r'[^0-9+]'), '');
  if (normalized.startsWith('+')) {
    return '+${normalized.substring(1).replaceAll(RegExp(r'[^0-9]'), '')}';
  }

  if (normalized.startsWith('00')) {
    return '+${normalized.substring(2)}';
  }

  if (normalized.startsWith('964')) {
    return '+$normalized';
  }

  if (normalized.startsWith('07') && normalized.length == 11) {
    return '+964${normalized.substring(1)}';
  }

  if (normalized.startsWith('7') && normalized.length == 10) {
    return '+964$normalized';
  }

  return normalized;
}

String formatPhoneNumberForDisplay(String? rawPhoneNumber) {
  if (rawPhoneNumber == null || rawPhoneNumber.trim().isEmpty) {
    return '';
  }

  final local = normalizePhoneNumberForLocalInput(rawPhoneNumber);
  if (local.length == 11 && local.startsWith('07')) {
    return local;
  }

  final normalized = _normalizeNumerals(
    rawPhoneNumber,
  ).replaceAll(RegExp(r'[^0-9+]'), '');
  if (normalized.startsWith('+') && normalized.length > 1) {
    return normalized;
  }

  return rawPhoneNumber.trim();
}
