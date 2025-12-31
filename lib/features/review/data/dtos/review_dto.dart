import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewDto {
  final String bookingId;
  final String reviewerId;
  final String targetId;
  final int rating;
  final String? comment;
  final DateTime createdAt;

  const ReviewDto({
    required this.bookingId,
    required this.reviewerId,
    required this.targetId,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'bookingId': bookingId,
      'reviewerId': reviewerId,
      'targetId': targetId,
      'rating': rating,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
