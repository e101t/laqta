String normalizePhoneNumberForFirebase(String rawPhoneNumber) {
  final trimmed = rawPhoneNumber.trim();
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
