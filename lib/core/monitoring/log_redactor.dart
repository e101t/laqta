/// Shared redaction for anything that leaves the device (logs, Sentry).
class LogRedactor {
  LogRedactor._();

  static final RegExp _queryPattern = RegExp(
    r'([?&](token|password|secret|client_secret)=)[^&]+',
    caseSensitive: false,
  );

  static final RegExp _pairPattern = RegExp(
    r'(token|password|secret|client_secret)=([^&\s]+)',
    caseSensitive: false,
  );

  static final RegExp _bearerPattern = RegExp(r'Bearer\s+[A-Za-z0-9._-]+');

  static String redact(String value) {
    return value
        .replaceAll(_queryPattern, r'$1REDACTED')
        .replaceAll(_pairPattern, r'$1=REDACTED')
        .replaceAll(_bearerPattern, 'Bearer REDACTED');
  }
}
