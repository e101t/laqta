import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:laqta/core/utils/firestore_parsers.dart';

class StoryModel {
  final String storyId;
  final String photographerId;
  final String photographerName;
  final String? photographerPhotoUrl;
  final String imageUrl;
  final String? caption;
  final DateTime createdAt;
  final DateTime expiresAt; // Auto-delete after 24 hours
  final List<StoryView> views;
  final bool isActive; // Still within 24 hours

  StoryModel({
    required this.storyId,
    required this.photographerId,
    required this.photographerName,
    this.photographerPhotoUrl,
    required this.imageUrl,
    this.caption,
    required this.createdAt,
    required this.expiresAt,
    this.views = const [],
    required this.isActive,
  });

  factory StoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = firestoreMap(doc.data());
    final createdAt = readDate(data['createdAt']) ?? DateTime.now();
    final expiresAt =
        readDate(data['expiresAt']) ?? createdAt.add(const Duration(hours: 24));

    return StoryModel(
      storyId: doc.id,
      photographerId: readString(data, 'photographerId'),
      photographerName: readString(data, 'photographerName'),
      photographerPhotoUrl: readNullableString(data, 'photographerPhotoUrl'),
      imageUrl: readString(data, 'imageUrl'),
      caption: readNullableString(data, 'caption'),
      createdAt: createdAt,
      expiresAt: expiresAt,
      views: _parseViews(data['views']),
      isActive: DateTime.now().isBefore(expiresAt),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'photographerId': photographerId,
      'photographerName': photographerName,
      'photographerPhotoUrl': photographerPhotoUrl,
      'imageUrl': imageUrl,
      'caption': caption,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'isActive': isActive,
    };
  }

  bool hasUserViewed(String userId) {
    return views.any((view) => view.userId == userId);
  }

  int get viewsCount => views.length;

  static List<StoryView> _parseViews(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map<dynamic, dynamic>>()
        .map((view) => StoryView.fromMap(Map<String, dynamic>.from(view)))
        .toList();
  }

  String getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inHours > 0) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inMinutes > 0) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else {
      return 'الآن';
    }
  }

  String getTimeRemaining() {
    final now = DateTime.now();
    final remaining = expiresAt.difference(now);

    if (remaining.inHours > 0) {
      return 'باقي ${remaining.inHours} ساعة';
    } else if (remaining.inMinutes > 0) {
      return 'باقي ${remaining.inMinutes} دقيقة';
    } else {
      return 'تنتهي قريباً';
    }
  }
}

class StoryView {
  final String userId;
  final String userName;
  final DateTime viewedAt;

  StoryView({
    required this.userId,
    required this.userName,
    required this.viewedAt,
  });

  factory StoryView.fromMap(Map<String, dynamic> map) {
    return StoryView(
      userId: readString(map, 'userId'),
      userName: readString(map, 'userName'),
      viewedAt: readDateTime(map, 'viewedAt'),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'viewedAt': Timestamp.fromDate(viewedAt),
    };
  }
}
