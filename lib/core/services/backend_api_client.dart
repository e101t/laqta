import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
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
  BackendApiClient({BackendSessionService? sessionService, http.Client? client})
    : _sessionService = sessionService ?? BackendSessionService(),
      _client = client ?? http.Client();

  final BackendSessionService _sessionService;
  final http.Client _client;

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
    final headers = <String, String>{'Accept': 'application/json'};

    if (authorized) {
      final token = await _sessionService.getToken();
      if (token == null || token.isEmpty) {
        throw const BackendApiException('Missing backend session.');
      }
      headers['Authorization'] = 'Bearer $token';
    }

    final uri = BackendConfig.apiUri(path);
    final request = http.MultipartRequest('POST', uri);
    request.headers.addAll(headers);
    request.files.add(await http.MultipartFile.fromPath(fieldName, filePath));

    final streamedResponse = await _client.send(request);
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return null;
      }
      return jsonDecode(response.body);
    }

    String message = 'File upload failed.';
    if (response.body.isNotEmpty) {
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          final backendMessage = decoded['message'];
          if (backendMessage is String && backendMessage.isNotEmpty) {
            message = backendMessage;
          }
        }
      } catch (_) {
        message = response.body;
      }
    }

    throw BackendApiException(message, statusCode: response.statusCode);
  }

  Future<dynamic> _send({
    required String method,
    required String path,
    Map<String, dynamic>? body,
    required bool authorized,
    bool retryOnUnauthorized = true,
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (authorized) {
      final token = await _sessionService.getToken();
      if (token == null || token.isEmpty) {
        throw const BackendApiException('Missing backend session.');
      }
      headers['Authorization'] = 'Bearer $token';
    }

    final uri = BackendConfig.apiUri(path);
    final encodedBody = body == null ? null : jsonEncode(body);

    late final http.Response response;
    switch (method) {
      case 'GET':
        response = await _client.get(uri, headers: headers);
        break;
      case 'POST':
        response = await _client.post(uri, headers: headers, body: encodedBody);
        break;
      case 'PATCH':
        response = await _client.patch(
          uri,
          headers: headers,
          body: encodedBody,
        );
        break;
      case 'DELETE':
        response = await _client.delete(uri, headers: headers);
        break;
      default:
        throw BackendApiException('Unsupported method: $method');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return null;
      }
      return jsonDecode(response.body);
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

    String message = 'Backend request failed.';
    if (response.body.isNotEmpty) {
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          final backendMessage = decoded['message'];
          if (backendMessage is String && backendMessage.isNotEmpty) {
            message = backendMessage;
          }
        }
      } catch (_) {
        message = response.body;
      }
    }

    throw BackendApiException(message, statusCode: response.statusCode);
  }

  Future<bool> _refreshBackendSession() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return false;
    }

    final idToken = await user.getIdToken(true);
    if (idToken == null || idToken.isEmpty) {
      return false;
    }

    final uri = BackendConfig.apiUri('/auth/firebase/exchange');
    final response = await _client.post(
      uri,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'idToken': idToken,
        if (user.displayName != null && user.displayName!.trim().isNotEmpty)
          'name': user.displayName!.trim(),
      }),
    );

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

    final token = decoded['token'];
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
    }

    await _sessionService.saveSession(token: token, userId: userId);
    return true;
  }
}
