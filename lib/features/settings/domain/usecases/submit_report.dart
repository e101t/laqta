import 'package:laqta/core/domain/result/result.dart';
import '../entities/report_submission.dart';
import '../repositories/settings_repository.dart';

class SubmitReport {
  final SettingsRepository _repository;

  const SubmitReport(this._repository);

  Future<Result<void>> call(ReportSubmission submission) {
    return _repository.submitReport(submission);
  }
}
