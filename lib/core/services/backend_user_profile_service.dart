import 'package:laqta/core/services/backend_api_client.dart';

class BackendUserProfileService {
  BackendUserProfileService({BackendApiClient? apiClient})
    : _apiClient = apiClient ?? BackendApiClient();

  final BackendApiClient _apiClient;

  Future<void> syncProfile(Map<String, dynamic> profile) async {
    final payload = _buildPayload(profile);
    if (payload.isEmpty) {
      return;
    }

    await _apiClient.patch('/users/me', body: payload);
  }

  Map<String, dynamic> _buildPayload(Map<String, dynamic> profile) {
    final payload = <String, dynamic>{};

    void putString(String sourceKey, String targetKey) {
      final value = profile[sourceKey];
      if (value is String && value.trim().isNotEmpty) {
        payload[targetKey] = value.trim();
      }
    }

    void putNullableString(String sourceKey, String targetKey) {
      if (!profile.containsKey(sourceKey)) {
        return;
      }
      final value = profile[sourceKey];
      if (value == null) {
        payload[targetKey] = null;
        return;
      }
      if (value is String && value.trim().isNotEmpty) {
        payload[targetKey] = value.trim();
      }
    }

    if (profile.containsKey('role')) {
      final role = _normalizeRole(profile['role']);
      if (role != null) {
        payload['role'] = role;
      }
    }

    putString('name', 'name');
    putString('username', 'username');
    putString('usernameLower', 'username');
    putString('governorate', 'governorate');
    putNullableString('email', 'email');
    putNullableString('phone', 'phone');
    putNullableString('photoUrl', 'photoUrl');

    if (profile.containsKey('gender')) {
      final gender = _normalizeGender(profile['gender']);
      if (gender != null) {
        payload['gender'] = gender;
      }
    }

    if (profile.containsKey('birthYear')) {
      final birthYear = profile['birthYear'];
      if (birthYear is int) {
        payload['birthYear'] = birthYear;
      }
    }

    if (profile.containsKey('profileCompleted') &&
        profile['profileCompleted'] is bool) {
      payload['profileCompleted'] = profile['profileCompleted'];
    }

    if (profile.containsKey('over18Confirmed') &&
        profile['over18Confirmed'] is bool) {
      payload['over18Confirmed'] = profile['over18Confirmed'];
    }

    return payload;
  }

  String? _normalizeRole(dynamic value) {
    if (value is! String) {
      return null;
    }

    final normalized = value.trim().toLowerCase();
    switch (normalized) {
      case 'customer':
      case 'photographer':
      case 'both':
        return normalized;
      default:
        return null;
    }
  }

  String? _normalizeGender(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is! String) {
      return null;
    }

    final normalized = value.trim().toLowerCase();
    switch (normalized) {
      case 'male':
      case 'female':
      case 'undisclosed':
        return normalized;
      default:
        return null;
    }
  }
}
