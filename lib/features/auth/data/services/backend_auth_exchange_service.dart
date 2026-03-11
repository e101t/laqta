import 'package:firebase_auth/firebase_auth.dart';
import 'package:luqta/core/services/backend_api_client.dart';
import 'package:luqta/core/services/backend_notification_sync_service.dart';
import 'package:luqta/core/services/backend_session_service.dart';

class BackendAuthExchangeService {
  BackendAuthExchangeService({
    FirebaseAuth? auth,
    BackendApiClient? apiClient,
    BackendSessionService? sessionService,
    BackendNotificationSyncService? notificationSyncService,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _apiClient = apiClient ?? BackendApiClient(),
       _sessionService = sessionService ?? const BackendSessionService(),
       _notificationSyncService =
           notificationSyncService ?? BackendNotificationSyncService.instance;

  final FirebaseAuth _auth;
  final BackendApiClient _apiClient;
  final BackendSessionService _sessionService;
  final BackendNotificationSyncService _notificationSyncService;

  Future<bool> ensureBackendSession() async {
    final existingToken = await _sessionService.getToken();
    if (existingToken != null && existingToken.isNotEmpty) {
      return false;
    }

    if (_auth.currentUser == null) {
      return false;
    }

    await exchangeCurrentFirebaseUser();
    return true;
  }

  Future<void> exchangeCurrentFirebaseUser() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('No authenticated Firebase user');
    }

    final idToken = await user.getIdToken(true);
    if (idToken == null || idToken.isEmpty) {
      throw StateError('Missing Firebase ID token');
    }

    final response = await _apiClient.post(
      '/auth/firebase/exchange',
      authorized: false,
      body: {
        'idToken': idToken,
        if (user.displayName != null && user.displayName!.trim().isNotEmpty)
          'name': user.displayName!.trim(),
      },
    );

    if (response is! Map<String, dynamic>) {
      throw const BackendApiException('Invalid backend auth response.');
    }

    final token = response['token'];
    final backendUser = response['user'];
    if (token is! String || token.isEmpty) {
      throw const BackendApiException('Missing backend token.');
    }

    String? userId;
    if (backendUser is Map<String, dynamic>) {
      final rawUserId = backendUser['id'];
      if (rawUserId is String && rawUserId.isNotEmpty) {
        userId = rawUserId;
      }
    }

    await _sessionService.saveSession(token: token, userId: userId);
    await _notificationSyncService.syncCurrentDeviceToken();
  }

  Future<void> clearSession() {
    return _sessionService.clear();
  }
}
