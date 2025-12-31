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

  const ReelModel({
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
