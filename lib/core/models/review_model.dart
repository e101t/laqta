import 'package:laqta/core/utils/legacy_data_compat.dart';

import 'package:laqta/core/utils/firestore_parsers.dart';

class ReviewModel {
  final String id;
  final String bookingId;
  final String reviewerId;
  final String targetId; // photographerId
  final int rating; // 1-5
  final int qualityRating;
  final int communicationRating;
  final int onTimeRating;
  final int deliverySpeedRating;
  final bool? recommend;
  final String? comment;
  final DateTime createdAt;

  ReviewModel({
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

  factory ReviewModel.fromFirestore(DocumentSnapshot doc) {
    final data = firestoreMap(doc.data());
    return ReviewModel(
      id: doc.id,
      bookingId: readString(data, 'bookingId'),
      reviewerId: readString(data, 'reviewerId'),
      targetId: readString(data, 'targetId'),
      rating: readInt(data, 'rating', defaultValue: 5),
      qualityRating: readInt(data, 'qualityRating', defaultValue: 5),
      communicationRating: readInt(
        data,
        'communicationRating',
        defaultValue: 5,
      ),
      onTimeRating: readInt(data, 'onTimeRating', defaultValue: 5),
      deliverySpeedRating: readInt(
        data,
        'deliverySpeedRating',
        defaultValue: 5,
      ),
      recommend: data['recommend'] is bool ? data['recommend'] as bool : null,
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
