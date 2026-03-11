import 'package:luqta/core/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackendSessionService {
  const BackendSessionService();

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.keyBackendJwt);
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.keyBackendUserId);
  }

  Future<void> saveSession({
    required String token,
    String? userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyBackendJwt, token);
    if (userId != null && userId.isNotEmpty) {
      await prefs.setString(AppConstants.keyBackendUserId, userId);
    }
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.keyBackendJwt);
    await prefs.remove(AppConstants.keyBackendUserId);
  }
}
