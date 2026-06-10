import 'package:laqta/core/domain/result/result.dart';
import '../entities/review_submission.dart';

abstract class ReviewRepository {
  Future<Result<void>> submitReview(ReviewSubmission submission);
}
