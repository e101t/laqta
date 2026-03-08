class PhotographerReview {
  final String id;
  final String bookingId;
  final String reviewerId;
  final String targetId;
  final int rating;
  final int qualityRating;
  final int communicationRating;
  final int onTimeRating;
  final int deliverySpeedRating;
  final bool? recommend;
  final String? comment;
  final DateTime createdAt;

  const PhotographerReview({
    required this.id,
    required this.bookingId,
    required this.reviewerId,
    required this.targetId,
    required this.rating,
    required this.qualityRating,
    required this.communicationRating,
    required this.onTimeRating,
    required this.deliverySpeedRating,
    this.recommend,
    this.comment,
    required this.createdAt,
  });
}
