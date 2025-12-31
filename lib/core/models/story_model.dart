import 'package:cloud_firestore/cloud_firestore.dart';

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
    final data = doc.data() as Map<String, dynamic>;
    final createdAt =
        (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
    final expiresAt =
        (data['expiresAt'] as Timestamp?)?.toDate() ??
        createdAt.add(const Duration(hours: 24));

    return StoryModel(
      storyId: doc.id,
      photographerId: data['photographerId'] ?? '',
      photographerName: data['photographerName'] ?? '',
      photographerPhotoUrl: data['photographerPhotoUrl'],
      imageUrl: data['imageUrl'] ?? '',
      caption: data['caption'],
      createdAt: createdAt,
      expiresAt: expiresAt,
      views:
          (data['views'] as List<dynamic>?)
              ?.map((v) => StoryView.fromMap(v as Map<String, dynamic>))
              .toList() ??
          [],
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
      'views': views.map((v) => v.toMap()).toList(),
      'isActive': isActive,
    };
  }

  bool hasUserViewed(String userId) {
    return views.any((view) => view.userId == userId);
  }

  int get viewsCount => views.length;

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
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      viewedAt: (map['viewedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
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
