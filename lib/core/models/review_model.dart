import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:luqta/core/utils/firestore_parsers.dart';

class ReviewModel {
  final String id;
  final String bookingId;
  final String reviewerId;
  final String targetId; // photographerId
  final int rating; // 1-5
  final String? comment;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.bookingId,
    required this.reviewerId,
    required this.targetId,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory ReviewModel.fromFirestore(DocumentSnapshot doc) {
    final data = firestoreMap(doc.data());
    return ReviewModel(
      id: doc.id,
      bookingId: readString(data, 'bookingId'),
      reviewerId: readString(data, 'reviewerId'),
      targetId: readString(data, 'targetId'),
      rating: readInt(data, 'rating', defaultValue: 5),
      comment: readNullableString(data, 'comment'),
      createdAt: readDateTime(data, 'createdAt'),
    );
  }

  Map<String, dynamic> toFirestore() {
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
