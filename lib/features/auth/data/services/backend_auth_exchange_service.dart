import 'package:laqta/core/services/backend_session_service.dart';

class BackendAuthExchangeService {
  BackendAuthExchangeService({BackendSessionService? sessionService})
    : _sessionService = sessionService ?? BackendSessionService();

  final BackendSessionService _sessionService;

  Future<bool> ensureBackendSession() => _sessionService.hasValidToken();

  Future<void> clearSession() => _sessionService.clear();
}
