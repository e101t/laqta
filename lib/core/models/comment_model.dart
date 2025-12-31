import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:luqta/core/utils/firestore_parsers.dart';

class CommentModel {
  final String commentId;
  final String reelId;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final String text;
  final DateTime createdAt;
  final int likes;

  const CommentModel({
    required this.commentId,
    required this.reelId,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.text,
    required this.createdAt,
    this.likes = 0,
  });

  factory CommentModel.fromFirestore(DocumentSnapshot doc) {
    final data = firestoreMap(doc.data());
    return CommentModel(
      commentId: doc.id,
      reelId: readString(data, 'reelId'),
      userId: readString(data, 'userId'),
      userName: readString(data, 'userName', defaultValue: 'Unknown User'),
      userPhotoUrl: readNullableString(data, 'userPhotoUrl'),
      text: readString(data, 'text'),
      createdAt: readDateTime(data, 'createdAt'),
      likes: readInt(data, 'likes'),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'reelId': reelId,
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'text': text,
      'createdAt': Timestamp.fromDate(createdAt),
      'likes': likes,
    };
  }

  CommentModel copyWith({
    String? commentId,
    String? reelId,
    String? userId,
    String? userName,
    String? userPhotoUrl,
    String? text,
    DateTime? createdAt,
    int? likes,
  }) {
    return CommentModel(
      commentId: commentId ?? this.commentId,
      reelId: reelId ?? this.reelId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      likes: likes ?? this.likes,
    );
  }

  String getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return 'الآن';
    } else if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} يوم';
    } else {
      return '${difference.inDays ~/ 7} أسبوع';
    }
  }
}
