import 'dart:convert';

String testJwt({
  required DateTime expiresAt,
  String alg = 'HS256',
  String iss = 'https://api.laqta.cloud',
  Object aud = 'laqta-app',
  DateTime? issuedAt,
}) {
  final now = issuedAt ?? DateTime.now();
  final header = <String, Object?>{'alg': alg, 'typ': 'JWT'};
  final payload = <String, Object?>{
    'iss': iss,
    'aud': aud,
    'iat': now.millisecondsSinceEpoch ~/ 1000,
    'exp': expiresAt.millisecondsSinceEpoch ~/ 1000,
    'sub': 'test-user',
  };
  return '${_part(header)}.${_part(payload)}.signature';
}

String _part(Map<String, Object?> value) {
  return base64Url.encode(utf8.encode(jsonEncode(value))).replaceAll('=', '');
}
