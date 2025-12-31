class Failure {
  final String message;
  final String? code;

  const Failure({required this.message, this.code});

  @override
  String toString() {
    if (code == null) {
      return 'Failure(message: $message)';
    }
    return 'Failure(message: $message, code: $code)';
  }
}
