import 'package:laqta/core/domain/failures/failure.dart';
import 'package:laqta/core/domain/result/result.dart';
import 'package:laqta/features/review/data/datasources/review_remote_data_source.dart';
import 'package:laqta/features/review/data/mappers/review_mapper.dart';
import 'package:laqta/features/review/domain/entities/review_submission.dart';
import 'package:laqta/features/review/domain/repositories/review_repository.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final ReviewRemoteDataSource _remoteDataSource;

  const ReviewRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<void>> submitReview(ReviewSubmission submission) async {
    try {
      final dto = ReviewMapper.toDto(submission);
      await _remoteDataSource.submitReview(dto);
      return Result.success(null);
    } catch (_) {
      return Result.failure(const Failure(message: 'Failed to submit review'));
    }
  }
}
