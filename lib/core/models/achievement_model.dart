import 'package:laqta/core/localization/app_localizations.dart';

// Achievements & Gamification System

class Achievement {
  final String achievementId;
  final String title;
  final String description;
  final String icon;
  final int requiredCount;
  final String type;
  final int rewardPoints;

  Achievement({
    required this.achievementId,
    required this.title,
    required this.description,
    required this.icon,
    required this.requiredCount,
    required this.type,
    this.rewardPoints = 0,
  });

  static List<Achievement> getAllAchievements() {
    return [
      Achievement(
        achievementId: 'first_booking',
        title: AppLocalizations.current.achFirstBookingTitle,
        description: AppLocalizations.current.achFirstBookingDesc,
        icon: '🎉',
        requiredCount: 1,
        type: 'bookings',
        rewardPoints: 100,
      ),
      Achievement(
        achievementId: 'booking_master',
        title: AppLocalizations.current.achBookingExpertTitle,
        description: AppLocalizations.current.achBookingExpertDesc,
        icon: '⭐',
        requiredCount: 10,
        type: 'bookings',
        rewardPoints: 300,
      ),
      Achievement(
        achievementId: 'booking_pro',
        title: AppLocalizations.current.achBookingProTitle,
        description: AppLocalizations.current.achBookingProDesc,
        icon: '🌟',
        requiredCount: 50,
        type: 'bookings',
        rewardPoints: 1000,
      ),
      Achievement(
        achievementId: 'review_collector',
        title: AppLocalizations.current.achReviewCollectorTitle,
        description: AppLocalizations.current.achReviewCollectorDesc,
        icon: '💬',
        requiredCount: 50,
        type: 'reviews',
        rewardPoints: 500,
      ),
      Achievement(
        achievementId: 'top_rated',
        title: AppLocalizations.current.achTopRatedTitle,
        description: AppLocalizations.current.achTopRatedDesc,
        icon: '🏆',
        requiredCount: 48,
        type: 'rating',
        rewardPoints: 800,
      ),
      Achievement(
        achievementId: 'popular',
        title: AppLocalizations.current.achPopularTitle,
        description: AppLocalizations.current.achPopularDesc,
        icon: '👥',
        requiredCount: 100,
        type: 'followers',
        rewardPoints: 600,
      ),
      Achievement(
        achievementId: 'early_bird',
        title: AppLocalizations.current.achEarlyBirdTitle,
        description: AppLocalizations.current.achEarlyBirdDesc,
        icon: '🐦',
        requiredCount: 5,
        type: 'early_bookings',
        rewardPoints: 200,
      ),
      Achievement(
        achievementId: 'night_owl',
        title: AppLocalizations.current.achNightOwlTitle,
        description: AppLocalizations.current.achNightOwlDesc,
        icon: '🦉',
        requiredCount: 5,
        type: 'late_bookings',
        rewardPoints: 200,
      ),
      Achievement(
        achievementId: 'money_maker',
        title: AppLocalizations.current.achMoneyMakerTitle,
        description: AppLocalizations.current.achMoneyMakerDesc,
        icon: '💰',
        requiredCount: 5000000,
        type: 'revenue',
        rewardPoints: 1500,
      ),
    ];
  }
}

class UserAchievement {
  final String userId;
  final String achievementId;
  final int currentProgress;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  UserAchievement({
    required this.userId,
    required this.achievementId,
    this.currentProgress = 0,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  factory UserAchievement.fromJson(Map<String, dynamic> json) {
    return UserAchievement(
      userId: _readString(json['userId']),
      achievementId: _readString(json['achievementId']),
      currentProgress: _readInt(json['currentProgress']),
      isUnlocked: _readBool(json['isUnlocked']),
      unlockedAt: _readDate(json['unlockedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'achievementId': achievementId,
      'currentProgress': currentProgress,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
    };
  }

  double getProgress(Achievement achievement) {
    if (isUnlocked) return 1.0;
    return (currentProgress / achievement.requiredCount).clamp(0.0, 1.0);
  }

  UserAchievement copyWith({
    int? currentProgress,
    bool? isUnlocked,
    DateTime? unlockedAt,
  }) {
    return UserAchievement(
      userId: userId,
      achievementId: achievementId,
      currentProgress: currentProgress ?? this.currentProgress,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }
}

String _readString(dynamic value) {
  if (value == null) return '';
  if (value is String) return value;
  return value.toString();
}

int _readInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

bool _readBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.toLowerCase();
    if (normalized == 'true' || normalized == '1') return true;
    if (normalized == 'false' || normalized == '0') return false;
  }
  return false;
}

DateTime? _readDate(dynamic value) {
  if (value is DateTime) return value;
  if (value is num) return DateTime.fromMillisecondsSinceEpoch(value.toInt());
  if (value is String) {
    final parsed = DateTime.tryParse(value);
    if (parsed != null) return parsed;
    final millis = int.tryParse(value);
    if (millis != null) return DateTime.fromMillisecondsSinceEpoch(millis);
  }
  return null;
}
