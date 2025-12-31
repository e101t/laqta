// Achievements & Gamification System

class Timestamp {
  final DateTime dateTime;
  Timestamp.fromDate(this.dateTime);
  DateTime toDate() => dateTime;
}

class DocumentSnapshot {
  final String id;
  final Map<String, dynamic>? _data;
  DocumentSnapshot(this.id, this._data);
  Map<String, dynamic>? data() => _data;
}

class Achievement {
  final String achievementId;
  final String title;
  final String description;
  final String icon;
  final int requiredCount;
  final String type; // bookings, reviews, followers, revenue, etc.
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
        title: 'أول حجز 🎉',
        description: 'أتممت أول حجز لك',
        icon: '🎉',
        requiredCount: 1,
        type: 'bookings',
        rewardPoints: 100,
      ),
      Achievement(
        achievementId: 'booking_master',
        title: 'خبير الحجوزات ⭐',
        description: 'أتممت 10 حجوزات',
        icon: '⭐',
        requiredCount: 10,
        type: 'bookings',
        rewardPoints: 300,
      ),
      Achievement(
        achievementId: 'booking_pro',
        title: 'محترف الحجوزات 🌟',
        description: 'أتممت 50 حجز',
        icon: '🌟',
        requiredCount: 50,
        type: 'bookings',
        rewardPoints: 1000,
      ),
      Achievement(
        achievementId: 'review_collector',
        title: 'جامع التقييمات 💬',
        description: 'حصلت على 50 تقييم',
        icon: '💬',
        requiredCount: 50,
        type: 'reviews',
        rewardPoints: 500,
      ),
      Achievement(
        achievementId: 'top_rated',
        title: 'الأعلى تقييماً 🏆',
        description: 'متوسط تقييمك 4.8+',
        icon: '🏆',
        requiredCount: 48, // 4.8 * 10
        type: 'rating',
        rewardPoints: 800,
      ),
      Achievement(
        achievementId: 'popular',
        title: 'مشهور 👥',
        description: 'لديك 100 متابع',
        icon: '👥',
        requiredCount: 100,
        type: 'followers',
        rewardPoints: 600,
      ),
      Achievement(
        achievementId: 'early_bird',
        title: 'الطائر المبكر 🐦',
        description: 'أتممت 5 حجوزات قبل الساعة 9 صباحاً',
        icon: '🐦',
        requiredCount: 5,
        type: 'early_bookings',
        rewardPoints: 200,
      ),
      Achievement(
        achievementId: 'night_owl',
        title: 'بومة الليل 🦉',
        description: 'أتممت 5 حجوزات بعد الساعة 8 مساءً',
        icon: '🦉',
        requiredCount: 5,
        type: 'late_bookings',
        rewardPoints: 200,
      ),
      Achievement(
        achievementId: 'money_maker',
        title: 'صانع المال 💰',
        description: 'حققت إيرادات 5 مليون دينار',
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

  factory UserAchievement.fromFirestore(dynamic doc) {
    final data = _safeData(doc);
    return UserAchievement(
      userId: _readString(data['userId']),
      achievementId: _readString(data['achievementId']),
      currentProgress: _readInt(data['currentProgress']),
      isUnlocked: _readBool(data['isUnlocked']),
      unlockedAt: _readDate(data['unlockedAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'achievementId': achievementId,
      'currentProgress': currentProgress,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt != null ? Timestamp.fromDate(unlockedAt!) : null,
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

Map<String, dynamic> _safeData(dynamic doc) {
  if (doc is Map<String, dynamic>) return doc;
  if (doc is Map) return Map<String, dynamic>.from(doc);
  if (doc is DocumentSnapshot) return doc.data() ?? <String, dynamic>{};
  try {
    final raw = doc?.data();
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
  } catch (_) {}
  return <String, dynamic>{};
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
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is num) {
    return DateTime.fromMillisecondsSinceEpoch(value.toInt());
  }
  if (value is String) {
    final parsed = DateTime.tryParse(value);
    if (parsed != null) return parsed;
    final millis = int.tryParse(value);
    if (millis != null) {
      return DateTime.fromMillisecondsSinceEpoch(millis);
    }
  }
  return null;
}
