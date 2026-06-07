import 'dart:convert';

class JwtValidationResult {
  const JwtValidationResult._({
    required this.isValid,
    this.reason,
    this.expiry,
  });

  const JwtValidationResult.valid({DateTime? expiry})
    : this._(isValid: true, expiry: expiry);

  const JwtValidationResult.invalid(String reason)
    : this._(isValid: false, reason: reason);

  final bool isValid;
  final String? reason;
  final DateTime? expiry;
}

class JwtValidator {
  const JwtValidator({
    required this.expectedIssuer,
    required this.expectedAudience,
    this.allowedAlgorithms = const <String>{'HS256', 'RS256'},
    this.allowMissingIssuerAudience = true,
  });

  final String expectedIssuer;
  final String expectedAudience;
  final Set<String> allowedAlgorithms;
  final bool allowMissingIssuerAudience;

  JwtValidationResult validateAccessToken(String token) {
    return validate(token, maxLifetime: const Duration(minutes: 15));
  }

  JwtValidationResult validateRefreshToken(String token) {
    return validate(token, maxLifetime: const Duration(days: 7));
  }

  JwtValidationResult validate(String token, {required Duration maxLifetime}) {
    final parsed = parse(token);
    if (parsed == null) {
      return const JwtValidationResult.invalid('malformed_token');
    }

    final algorithm = parsed.header['alg']?.toString();
    if (algorithm == null || algorithm.toLowerCase() == 'none') {
      return const JwtValidationResult.invalid('unsafe_algorithm');
    }
    if (!allowedAlgorithms.contains(algorithm)) {
      return JwtValidationResult.invalid('unexpected_algorithm:$algorithm');
    }

    final expiry = _dateFromSeconds(parsed.payload['exp']);
    if (expiry == null) {
      return const JwtValidationResult.invalid('missing_exp');
    }
    if (!DateTime.now().isBefore(expiry)) {
      return const JwtValidationResult.invalid('expired');
    }

    final issuedAt = _dateFromSeconds(parsed.payload['iat']);
    if (issuedAt != null && expiry.difference(issuedAt) > maxLifetime) {
      return const JwtValidationResult.invalid('lifetime_too_long');
    }

    final issuer = parsed.payload['iss']?.toString();
    if (!_matchesClaim(issuer, expectedIssuer)) {
      return const JwtValidationResult.invalid('wrong_issuer');
    }

    final audience = parsed.payload['aud'];
    if (!_matchesAudience(audience, expectedAudience)) {
      return const JwtValidationResult.invalid('wrong_audience');
    }

    return JwtValidationResult.valid(expiry: expiry);
  }

  static ParsedJwt? parse(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      return null;
    }
    try {
      final header = _decodePart(parts[0]);
      final payload = _decodePart(parts[1]);
      if (header is! Map<String, dynamic> || payload is! Map<String, dynamic>) {
        return null;
      }
      return ParsedJwt(header: header, payload: payload);
    } catch (_) {
      return null;
    }
  }

  bool _matchesClaim(String? actual, String expected) {
    if (expected.isEmpty) {
      return true;
    }
    if (actual == null || actual.isEmpty) {
      return allowMissingIssuerAudience;
    }
    return actual == expected;
  }

  bool _matchesAudience(Object? actual, String expected) {
    if (expected.isEmpty) {
      return true;
    }
    if (actual == null) {
      return allowMissingIssuerAudience;
    }
    if (actual is String) {
      return actual == expected;
    }
    if (actual is List) {
      return actual.map((value) => value.toString()).contains(expected);
    }
    return false;
  }

  static dynamic _decodePart(String encoded) {
    final normalized = base64Url.normalize(encoded);
    return jsonDecode(utf8.decode(base64Url.decode(normalized)));
  }

  static DateTime? _dateFromSeconds(Object? value) {
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value * 1000);
    }
    if (value is num) {
      return DateTime.fromMillisecondsSinceEpoch(value.toInt() * 1000);
    }
    return null;
  }
}

class ParsedJwt {
  const ParsedJwt({required this.header, required this.payload});

  final Map<String, dynamic> header;
  final Map<String, dynamic> payload;
}
