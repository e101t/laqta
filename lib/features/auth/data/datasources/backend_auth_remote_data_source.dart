import 'package:laqta/core/network/cache/cache_interceptor.dart';
import 'package:laqta/core/services/backend_api_client.dart';
import 'package:laqta/core/services/backend_notification_sync_service.dart';
import 'package:laqta/core/services/backend_session_service.dart';
import 'package:laqta/core/storage/secure_storage_manager.dart';
import 'package:laqta/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:laqta/features/auth/data/dtos/auth_user_dto.dart';
import 'package:laqta/features/auth/data/utils/phone_number_utils.dart';

class BackendAuthRemoteDataSource implements AuthRemoteDataSource {
  BackendAuthRemoteDataSource({
    BackendApiClient? apiClient,
    BackendSessionService? sessionService,
  }) : _apiClient = apiClient ?? BackendApiClient(),
       _sessionService = sessionService ?? BackendSessionService();

  final BackendApiClient _apiClient;
  final BackendSessionService _sessionService;
  AuthUserDto? _cachedUser;

  @override
  Future<AuthUserDto?> getCurrentUser() async {
    if (_cachedUser != null) {
      return _cachedUser;
    }

    final token = await _sessionService.getToken();
    if (token == null || token.isEmpty) {
      return null;
    }

    try {
      final decoded = await _apiClient
          .get('/users/me')
          .timeout(const Duration(seconds: 8));
      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      final userJson = decoded['user'];
      if (userJson is! Map<String, dynamic>) {
        return null;
      }

      _cachedUser = AuthUserDto.fromBackendJson(userJson);
      return _cachedUser;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<AuthUserDto> signInWithPassword({
    required String identifier,
    required String password,
  }) async {
    final decoded = await _apiClient.post(
      '/auth/login',
      authorized: false,
      body: {'identifier': identifier.trim(), 'password': password},
    );

    return _persistAuthResponse(decoded);
  }

  @override
  Future<AuthOtpStartDto> startRegistration({
    required String role,
    required String firstName,
    required String lastName,
    required String username,
    required String gender,
    required String birthdate,
    required String province,
    required String phone,
  }) async {
    final decoded = await _apiClient.post(
      '/auth/register/start',
      authorized: false,
      body: {
        'role': role,
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        'username': username.trim().toLowerCase(),
        'gender': gender,
        'birthdate': birthdate,
        'province': province,
        'phone': normalizePhoneNumberForOtp(phone),
      },
    );

    return _parseOtpStart(decoded);
  }

  @override
  Future<AuthUserDto> completeRegistration({
    required String requestId,
    required String code,
    required String password,
    required String confirmPassword,
  }) async {
    final decoded = await _apiClient.post(
      '/auth/register/complete',
      authorized: false,
      body: {
        'requestId': requestId,
        'code': code.trim(),
        'password': password,
        'confirmPassword': confirmPassword,
      },
    );

    return _persistAuthResponse(decoded);
  }

  @override
  Future<AuthOtpStartDto> forgotPassword({required String phone}) async {
    final decoded = await _apiClient.post(
      '/auth/password/forgot',
      authorized: false,
      body: {'phone': normalizePhoneNumberForOtp(phone)},
    );

    return _parseOtpStart(decoded);
  }

  @override
  Future<AuthUserDto> resetPassword({
    required String requestId,
    required String code,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final decoded = await _apiClient.post(
      '/auth/password/reset',
      authorized: false,
      body: {
        'requestId': requestId,
        'code': code.trim(),
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      },
    );

    return _persistAuthResponse(decoded);
  }

  @override
  Future<void> signOut() async {
    final refreshToken = await _sessionService.getRefreshToken();
    await BackendNotificationSyncService.instance.deleteCurrentDeviceToken();
    if (refreshToken != null && refreshToken.isNotEmpty) {
      try {
        await _apiClient.post(
          '/auth/logout',
          authorized: false,
          body: {'refreshToken': refreshToken},
        );
      } catch (_) {
        // Logout is local-first; backend revocation is best effort when offline.
      }
    }
    await _sessionService.clear();
    await CacheInterceptor().clearUserCache();
    SecureStorageManager.instance.clearMemoryTier();
    _cachedUser = null;
  }

  @override
  Future<void> deleteCurrentUser() async {
    throw UnsupportedError('حذف الحساب يتم عبر سياسة حذف الحساب حالياً.');
  }

  AuthOtpStartDto _parseOtpStart(Object? decoded) {
    if (decoded is! Map<String, dynamic>) {
      throw StateError('Invalid OTP response.');
    }
    final requestId = decoded['requestId'];
    if (requestId is! String || requestId.isEmpty) {
      throw StateError('OTP service did not return a request id.');
    }
    return AuthOtpStartDto(
      requestId: requestId,
      expiresInSeconds: decoded['expiresInSeconds'] is int
          ? decoded['expiresInSeconds'] as int
          : 300,
      resendAfterSeconds: decoded['resendAfterSeconds'] is int
          ? decoded['resendAfterSeconds'] as int
          : 60,
      message: decoded['message'] as String?,
    );
  }

  Future<AuthUserDto> _persistAuthResponse(Object? decoded) async {
    if (decoded is! Map<String, dynamic>) {
      throw StateError('Invalid authentication response.');
    }

    final accessToken = decoded['accessToken'] ?? decoded['token'];
    final refreshToken = decoded['refreshToken'];
    final userJson = decoded['user'];
    if (accessToken is! String || accessToken.isEmpty) {
      throw StateError('Authentication response is missing access token.');
    }
    if (userJson is! Map<String, dynamic>) {
      throw StateError('Authentication response is missing user payload.');
    }

    final user = AuthUserDto.fromBackendJson(userJson);
    await _sessionService.saveSession(
      token: accessToken,
      refreshToken: refreshToken is String ? refreshToken : null,
      userId: user.id,
    );
    _cachedUser = user;
    return user;
  }
}
