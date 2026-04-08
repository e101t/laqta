import 'package:cloud_functions/cloud_functions.dart'
    show FirebaseFunctionsException;
import 'package:laqta/core/domain/failures/failure.dart';
import 'package:laqta/core/domain/result/result.dart';
import 'package:laqta/features/settings/data/datasources/settings_remote_data_source.dart';
import 'package:laqta/features/settings/domain/entities/report_submission.dart';
import 'package:laqta/features/settings/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsRemoteDataSource _remoteDataSource;

  const SettingsRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<void>> submitReport(ReportSubmission submission) async {
    try {
      await _remoteDataSource.submitReport(submission);
      return Result.success(null);
    } catch (_) {
      return Result.failure(const Failure(message: 'Failed to submit report'));
    }
  }

  @override
  Future<Result<void>> deleteUserData({required String userId}) async {
    try {
      await _remoteDataSource.deleteUserData(userId);
      return Result.success(null);
    } on FirebaseFunctionsException catch (error) {
      return Result.failure(
        Failure(
          message: error.message ?? 'Failed to delete user data',
          code: error.code,
        ),
      );
    } catch (_) {
      return Result.failure(
        const Failure(message: 'Failed to delete user data'),
      );
    }
  }
}
