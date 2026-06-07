import 'package:laqta/core/launch/launch_config.dart';
import 'package:laqta/core/services/backend_api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LaunchConfigService {
  LaunchConfigService({BackendApiClient? apiClient})
    : _apiClient = apiClient ?? BackendApiClient();

  static const selectedCityKey = 'laqta_selected_city';

  final BackendApiClient _apiClient;

  Future<LaunchConfig?> fetchLaunchConfig() async {
    try {
      final response = await _apiClient
          .get('/config/launch', authorized: false)
          .timeout(const Duration(seconds: 6));
      if (response is Map<String, dynamic>) {
        final launch = response['launch'];
        if (launch is Map<String, dynamic>) {
          return LaunchConfig.fromJson(launch);
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<String> selectedCity() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(selectedCityKey) ?? 'Baghdad';
  }

  Future<void> saveSelectedCity(String city) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(selectedCityKey, city.trim());
  }

  Future<void> submitWaitlist(WaitlistEntryInput input) async {
    await _apiClient.post('/waitlist', body: input.toJson(), authorized: false);
  }
}
