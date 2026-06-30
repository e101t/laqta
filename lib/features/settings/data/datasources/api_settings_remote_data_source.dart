import 'package:laqta/core/services/backend_api_client.dart';
import 'package:laqta/features/settings/data/datasources/settings_remote_data_source.dart';
import 'package:laqta/features/settings/domain/entities/report_submission.dart';

class ApiSettingsRemoteDataSource implements SettingsRemoteDataSource {
  ApiSettingsRemoteDataSource({BackendApiClient? apiClient})
    : _apiClient = apiClient ?? BackendApiClient();

  final BackendApiClient _apiClient;

  @override
  Future<void> submitReport(ReportSubmission submission) async {
    await _apiClient.post('/reports', body: {
      'reporterId': submission.reporterId,
      'reportedUserId': submission.reportedUserId,
      'reportedUserName': submission.reportedUserName,
      'reportType': submission.reportType,
      'reason': submission.reason,
      'details': submission.details,
    });
  }

  @override
  Future<void> deleteUserData(String userId) async {
    await _apiClient.delete('/users/me');
  }
}
