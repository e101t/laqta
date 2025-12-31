import 'package:luqta/features/review/data/dtos/review_dto.dart';
import 'package:luqta/features/review/domain/entities/review_submission.dart';

class ReviewMapper {
  static ReviewDto toDto(ReviewSubmission submission) {
    return ReviewDto(
      bookingId: submission.bookingId,
      reviewerId: submission.reviewerId,
      targetId: submission.targetId,
      rating: submission.rating,
      comment: submission.comment,
      createdAt: submission.createdAt,
    );
  }
}
