import 'dart:convert';

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
  BackendApiClient({
    BackendSessionService? sessionService,
    http.Client? client,
  }) : _sessionService = sessionService ?? const BackendSessionService(),
       _client = client ?? http.Client();

  final BackendSessionService _sessionService;
  final http.Client _client;

  Future<dynamic> get(
    String path, {
    bool authorized = true,
  }) {
    return _send(
      method: 'GET',
      path: path,
      authorized: authorized,
    );
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

  Future<dynamic> delete(
    String path, {
    bool authorized = true,
  }) {
    return _send(
      method: 'DELETE',
      path: path,
      authorized: authorized,
    );
  }

  Future<dynamic> uploadFile(
    String path, {
    required String filePath,
    String fieldName = 'file',
    bool authorized = true,
  }) async {
    final headers = <String, String>{
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

    throw BackendApiException(
      message,
      statusCode: response.statusCode,
    );
  }

  Future<dynamic> _send({
    required String method,
    required String path,
    Map<String, dynamic>? body,
    required bool authorized,
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
        response = await _client.patch(uri, headers: headers, body: encodedBody);
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

    throw BackendApiException(
      message,
      statusCode: response.statusCode,
    );
  }
}
