import 'package:laqta/core/utils/legacy_data_compat.dart';

class ReviewDto {
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

  const ReviewDto({
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

  Map<String, dynamic> toMap() {
    return {
      'bookingId': bookingId,
      'reviewerId': reviewerId,
      'targetId': targetId,
      'rating': rating,
      'qualityRating': qualityRating,
      'communicationRating': communicationRating,
      'onTimeRating': onTimeRating,
      'deliverySpeedRating': deliverySpeedRating,
      'recommend': recommend,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
