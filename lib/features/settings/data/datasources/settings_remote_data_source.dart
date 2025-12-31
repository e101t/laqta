import 'package:luqta/features/settings/domain/entities/report_submission.dart';

abstract class SettingsRemoteDataSource {
  Future<void> submitReport(ReportSubmission submission);

  Future<void> deleteUserData(String userId);
}
