import 'package:laqta/core/domain/result/result.dart';
import '../entities/review_submission.dart';
import '../repositories/review_repository.dart';

class SubmitReview {
  final ReviewRepository _repository;

  const SubmitReview(this._repository);

  Future<Result<void>> call(ReviewSubmission submission) {
    return _repository.submitReview(submission);
  }
}
