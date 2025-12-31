import 'package:luqta/core/domain/result/result.dart';
import '../entities/report_submission.dart';

abstract class SettingsRepository {
  Future<Result<void>> submitReport(ReportSubmission submission);

  Future<Result<void>> deleteUserData({required String userId});
}
