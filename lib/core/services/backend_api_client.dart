import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:laqta/core/auth/auth_interceptor.dart';
import 'package:laqta/core/auth/session/anomaly_detector.dart';
import 'package:laqta/core/network/cache/cache_interceptor.dart';
import 'package:laqta/core/network/certificate_pinning.dart';
import 'package:laqta/core/network/request_signer.dart';
import 'package:laqta/core/security/monitoring/security_event_logger.dart';
import 'package:laqta/core/services/backend_config.dart';
import 'package:laqta/core/services/backend_session_service.dart';

class BackendApiException implements Exception {
  final String message;
  final int? statusCode;

  const BackendApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class BackendApiClient {
  BackendApiClient({
    BackendSessionService? sessionService,
    http.Client? client,
    AuthInterceptor? authInterceptor,
    RequestSigner? requestSigner,
    SessionAnomalyDetector? anomalyDetector,
    SecurityEventLogger? securityLogger,
    CacheInterceptor? cacheInterceptor,
  }) : _sessionService = sessionService ?? BackendSessionService(),
       _client = client ?? PinnedHttpClient(),
       _authInterceptor = authInterceptor ?? AuthInterceptor(),
       _requestSigner = requestSigner ?? RequestSigner(),
       _anomalyDetector = anomalyDetector ?? SessionAnomalyDetector.instance,
       _securityLogger = securityLogger ?? SecurityEventLogger.instance,
       _cacheInterceptor = cacheInterceptor ?? CacheInterceptor();

  final BackendSessionService _sessionService;
  final http.Client _client;
  final AuthInterceptor _authInterceptor;
  final RequestSigner _requestSigner;
  final SessionAnomalyDetector _anomalyDetector;
  final SecurityEventLogger _securityLogger;
  final CacheInterceptor _cacheInterceptor;

  Future<dynamic> get(String path, {bool authorized = true}) {
    return _send(method: 'GET', path: path, authorized: authorized);
  }

  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? body,
    bool authorized = true,
  }) {
    return _send(
      method: 'POST',
      path: path,
      body: body,
      authorized: authorized,
    );
  }

  Future<dynamic> patch(
    String path, {
    Map<String, dynamic>? body,
    bool authorized = true,
  }) {
    return _send(
      method: 'PATCH',
      path: path,
      body: body,
      authorized: authorized,
    );
  }

  Future<dynamic> delete(String path, {bool authorized = true}) {
    return _send(method: 'DELETE', path: path, authorized: authorized);
  }

  Future<dynamic> uploadFile(
    String path, {
    required String filePath,
    String fieldName = 'file',
    bool authorized = true,
  }) async {
    final uri = BackendConfig.apiUri(path);
    var headers = <String, String>{'Accept': 'application/json'};
    String? accessToken;

    if (authorized) {
      accessToken = await _sessionService.getToken();
      if (accessToken == null || accessToken.isEmpty) {
        throw const BackendApiException('Missing backend session.');
      }
      headers = await _authInterceptor.authorizedHeaders(baseHeaders: headers);
    }

    headers.addAll(
      await _requestSigner.buildHeaders(
        method: 'POST',
        uri: uri,
        accessToken: accessToken,
        sensitive: _isSensitivePath(path),
      ),
    );

    final request = http.MultipartRequest('POST', uri);
    request.headers.addAll(headers);
    request.files.add(await http.MultipartFile.fromPath(fieldName, filePath));

    final streamedResponse = await _client.send(request);
    final response = await http.Response.fromStream(streamedResponse);
    return _decodeOrThrow(response, defaultMessage: 'File upload failed.');
  }

  Future<dynamic> _send({
    required String method,
    required String path,
    Map<String, dynamic>? body,
    required bool authorized,
    bool retryOnUnauthorized = true,
    int rateLimitAttempt = 0,
  }) async {
    final uri = BackendConfig.apiUri(path);
    _recordRequestBurst(path);
    final encodedBody = body == null ? null : jsonEncode(body);
    var headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    String? accessToken;

    if (authorized) {
      accessToken = await _sessionService.getToken();
      if (accessToken == null || accessToken.isEmpty) {
        throw const BackendApiException('Missing backend session.');
      }
      headers = await _authInterceptor.authorizedHeaders(baseHeaders: headers);
    }

    headers.addAll(
      await _requestSigner.buildHeaders(
        method: method,
        uri: uri,
        body: encodedBody,
        accessToken: accessToken,
        sensitive: _isSensitivePath(path),
      ),
    );

    final cached = await _cacheInterceptor.readFresh(method, uri);
    if (cached != null) {
      return _decodeOrThrow(cached);
    }

    final response = await _dispatch(
      method: method,
      uri: uri,
      headers: headers,
      encodedBody: encodedBody,
    );
    await _cacheInterceptor.write(method, uri, response);

    if (_anomalyDetector.isSessionRevokedHeader(response.headers)) {
      await _sessionService.clear();
      await _securityLogger.log(
        'session_anomaly',
        severity: 'critical',
        details: <String, Object?>{'reason': 'session_revoked_header'},
      );
      throw const BackendApiException('Session revoked.', statusCode: 401);
    }

    if (response.statusCode == 429 && rateLimitAttempt < 3) {
      await Future<void>.delayed(_rateLimitDelay(rateLimitAttempt));
      return _send(
        method: method,
        path: path,
        body: body,
        authorized: authorized,
        retryOnUnauthorized: retryOnUnauthorized,
        rateLimitAttempt: rateLimitAttempt + 1,
      );
    }

    if (authorized && response.statusCode == 401 && retryOnUnauthorized) {
      final refreshed = await _refreshBackendSession();
      if (refreshed) {
        return _send(
          method: method,
          path: path,
          body: body,
          authorized: authorized,
          retryOnUnauthorized: false,
        );
      }
      await _sessionService.clear();
    }

    return _decodeOrThrow(response);
  }

  void _recordRequestBurst(String path) {
    if (_anomalyDetector.recordRequestAndDetectBurst()) {
      unawaited(
        _securityLogger.log(
          'session_anomaly',
          severity: 'warning',
          details: <String, Object?>{'reason': 'request_burst', 'path': path},
        ),
      );
    }
  }

  Future<http.Response> _dispatch({
    required String method,
    required Uri uri,
    required Map<String, String> headers,
    String? encodedBody,
  }) {
    switch (method) {
      case 'GET':
        return _client.get(uri, headers: headers);
      case 'POST':
        return _client.post(uri, headers: headers, body: encodedBody);
      case 'PATCH':
        return _client.patch(uri, headers: headers, body: encodedBody);
      case 'DELETE':
        return _client.delete(uri, headers: headers);
      default:
        throw BackendApiException('Unsupported method: $method');
    }
  }

  dynamic _decodeOrThrow(
    http.Response response, {
    String defaultMessage = 'Backend request failed.',
  }) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return null;
      }
      return jsonDecode(response.body);
    }

    var message = defaultMessage;
    if (response.body.isNotEmpty) {
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          final backendMessage = decoded['message'];
          if (backendMessage is String && backendMessage.isNotEmpty) {
            message = backendMessage;
          }
        } else if (decoded is String && decoded.isNotEmpty) {
          message = decoded;
        }
      } catch (_) {
        message = response.body;
      }
    }

    throw BackendApiException(message, statusCode: response.statusCode);
  }

  Future<bool> _refreshBackendSession() async {
    final refreshToken = await _sessionService.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      return false;
    }

    final uri = BackendConfig.apiUri('/auth/refresh');
    final body = jsonEncode({'refreshToken': refreshToken});
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      ...await _requestSigner.buildHeaders(
        method: 'POST',
        uri: uri,
        body: body,
        accessToken: refreshToken,
        sensitive: true,
      ),
    };

    final response = await _client.post(uri, headers: headers, body: body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      return false;
    }
    if (response.body.isEmpty) {
      return false;
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      return false;
    }

    final token = decoded['accessToken'] ?? decoded['token'];
    final rotatedRefresh = decoded['refreshToken'];
    final backendUser = decoded['user'];
    if (token is! String || token.isEmpty) {
      return false;
    }

    String? userId;
    if (backendUser is Map<String, dynamic>) {
      final rawUserId = backendUser['id'];
      if (rawUserId is String && rawUserId.isNotEmpty) {
        userId = rawUserId;
      }
    } else {
      userId = await _sessionService.getUserId();
    }

    await _sessionService.saveSession(
      token: token,
      refreshToken: rotatedRefresh is String && rotatedRefresh.isNotEmpty
          ? rotatedRefresh
          : refreshToken,
      userId: userId,
    );
    return true;
  }

  Duration _rateLimitDelay(int attempt) {
    return Duration(milliseconds: 350 * (1 << attempt));
  }

  bool _isSensitivePath(String path) {
    final normalized = path.startsWith('/') ? path : '/$path';
    return normalized.startsWith('/auth') ||
        normalized.startsWith('/payments') ||
        normalized.startsWith('/users') ||
        normalized.startsWith('/profile') ||
        normalized.contains('/bookings') ||
        normalized.contains('/campaigns') ||
        normalized.contains('/subscriptions/subscribe');
  }
}
