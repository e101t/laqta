// Reels Model - Short video content

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:luqta/core/utils/firestore_parsers.dart';

class ReelModel {
  final String reelId;
  final String photographerId;
  final String photographerName;
  final String? photographerPhotoUrl;
  final String videoUrl;
  final String? thumbnailUrl;
  final String caption;
  final List<String> tags;
  final int views;
  final int likes;
  final int comments;
  final int shares;
  final DateTime createdAt;
  final bool isVerified;

  ReelModel({
    required this.reelId,
    required this.photographerId,
    required this.photographerName,
    this.photographerPhotoUrl,
    required this.videoUrl,
    this.thumbnailUrl,
    required this.caption,
    this.tags = const [],
    this.views = 0,
    this.likes = 0,
    this.comments = 0,
    this.shares = 0,
    required this.createdAt,
    this.isVerified = false,
  });

  factory ReelModel.fromFirestore(DocumentSnapshot doc) {
    final data = firestoreMap(doc.data());
    return ReelModel(
      reelId: doc.id,
      photographerId: readString(data, 'photographerId'),
      photographerName: readString(data, 'photographerName'),
      photographerPhotoUrl: readNullableString(data, 'photographerPhotoUrl'),
      videoUrl: readString(data, 'videoUrl'),
      thumbnailUrl: readNullableString(data, 'thumbnailUrl'),
      caption: readString(data, 'caption'),
      tags: readStringList(data, 'tags'),
      views: readInt(data, 'views'),
      likes: readInt(data, 'likes'),
      comments: readInt(data, 'comments'),
      shares: readInt(data, 'shares'),
      createdAt: readDateTime(data, 'createdAt'),
      isVerified: readBool(data, 'isVerified'),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'photographerId': photographerId,
      'photographerName': photographerName,
      'photographerPhotoUrl': photographerPhotoUrl,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'caption': caption,
      'tags': tags,
      'views': views,
      'likes': likes,
      'comments': comments,
      'shares': shares,
      'createdAt': Timestamp.fromDate(createdAt),
      'isVerified': isVerified,
    };
  }

  String getViewsText() {
    if (views >= 1000000) {
      return '${(views / 1000000).toStringAsFixed(1)}M';
    } else if (views >= 1000) {
      return '${(views / 1000).toStringAsFixed(1)}K';
    } else {
      return '$views';
    }
  }

  String getLikesText() {
    if (likes >= 1000000) {
      return '${(likes / 1000000).toStringAsFixed(1)}M';
    } else if (likes >= 1000) {
      return '${(likes / 1000).toStringAsFixed(1)}K';
    } else {
      return '$likes';
    }
  }

  ReelModel copyWith({int? views, int? likes, int? comments, int? shares}) {
    return ReelModel(
      reelId: reelId,
      photographerId: photographerId,
      photographerName: photographerName,
      photographerPhotoUrl: photographerPhotoUrl,
      videoUrl: videoUrl,
      thumbnailUrl: thumbnailUrl,
      caption: caption,
      tags: tags,
      views: views ?? this.views,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      shares: shares ?? this.shares,
      createdAt: createdAt,
      isVerified: isVerified,
    );
  }
}
