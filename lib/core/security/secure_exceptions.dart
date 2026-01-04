class SecureException implements Exception {
  final String message;
  final String? code;

  const SecureException(this.message, {this.code});

  @override
  String toString() {
    if (code == null || code!.isEmpty) {
      return message;
    }
    return '$message ($code)';
  }
}
