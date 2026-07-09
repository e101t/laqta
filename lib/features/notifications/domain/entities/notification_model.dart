import 'package:laqta/core/localization/app_localizations.dart';

class NotificationModel {
  final String notificationId;
  final String userId;
  final String title;
  final String body;
  final String type; // booking, message, review, offer, system
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime createdAt;
  final String? imageUrl;
  final String? actionUrl;

  const NotificationModel({
    required this.notificationId,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.data,
    this.isRead = false,
    required this.createdAt,
    this.imageUrl,
    this.actionUrl,
  });

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      notificationId: notificationId,
      userId: userId,
      title: title,
      body: body,
      type: type,
      data: data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
      imageUrl: imageUrl,
      actionUrl: actionUrl,
    );
  }

  String getIcon() {
    switch (type) {
      case 'booking':
        return '📅';
      case 'message':
        return '💬';
      case 'review':
        return '⭐';
      case 'offer':
        return '💼';
      case 'request':
        return '📸';
      case 'payment':
        return '💳';
      case 'course':
        return '🎓';
      case 'system':
        return '🔔';
      default:
        return '🔔';
    }
  }

  String getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inSeconds < 60) {
      return AppLocalizations.current.justNow;
    } else if (difference.inMinutes < 60) {
      return AppLocalizations.current.minutesAgo(difference.inMinutes);
    } else if (difference.inHours < 24) {
      return AppLocalizations.current.hoursAgo(difference.inHours);
    } else if (difference.inDays < 7) {
      return AppLocalizations.current.daysAgo(difference.inDays);
    } else if (difference.inDays < 30) {
      return AppLocalizations.current.weeksAgo((difference.inDays / 7).floor());
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }
}
