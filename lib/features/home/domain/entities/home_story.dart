class HomeStory {
  final String storyId;
  final String photographerId;
  final String photographerName;
  final String? photographerPhotoUrl;
  final String imageUrl;
  final String? caption;
  final DateTime createdAt;
  final DateTime expiresAt;
  final List<HomeStoryView> views;
  final bool isActive;

  const HomeStory({
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

  bool hasUserViewed(String userId) {
    return views.any((view) => view.userId == userId);
  }

  int get viewsCount => views.length;

  String getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inHours > 0) {
      return '??? ${difference.inHours} ????';
    } else if (difference.inMinutes > 0) {
      return '??? ${difference.inMinutes} ?????';
    } else {
      return '????';
    }
  }

  String getTimeRemaining() {
    final now = DateTime.now();
    final remaining = expiresAt.difference(now);

    if (remaining.inHours > 0) {
      return '???? ${remaining.inHours} ????';
    } else if (remaining.inMinutes > 0) {
      return '???? ${remaining.inMinutes} ?????';
    } else {
      return '????? ??????';
    }
  }
}

class HomeStoryView {
  final String userId;
  final String userName;
  final DateTime viewedAt;

  const HomeStoryView({
    required this.userId,
    required this.userName,
    required this.viewedAt,
  });
}
