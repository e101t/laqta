class ReviewSubmission {
  final String bookingId;
  final String reviewerId;
  final String targetId;
  final int rating;
  final String? comment;
  final DateTime createdAt;

  const ReviewSubmission({
    required this.bookingId,
    required this.reviewerId,
    required this.targetId,
    required this.rating,
    this.comment,
    required this.createdAt,
  });
}
