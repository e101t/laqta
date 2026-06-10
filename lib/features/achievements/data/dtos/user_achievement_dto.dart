import 'package:laqta/core/utils/legacy_data_compat.dart';

class UserAchievementDto {
  final String id;
  final String userId;
  final String achievementId;
  final int currentProgress;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  const UserAchievementDto({
    required this.id,
    required this.userId,
    required this.achievementId,
    required this.currentProgress,
    required this.isUnlocked,
    this.unlockedAt,
  });

  factory UserAchievementDto.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return UserAchievementDto(
      id: doc.id,
      userId: _readString(data, 'userId'),
      achievementId: _readString(data, 'achievementId'),
      currentProgress: _readInt(data, 'currentProgress'),
      isUnlocked: _readBool(data, 'isUnlocked'),
      unlockedAt: _readNullableDateTime(data['unlockedAt']),
    );
  }

  static String _readString(
    Map<String, dynamic> data,
    String key, {
    String fallback = '',
  }) {
    final value = data[key];
    if (value is String) {
      return value;
    }
    return fallback;
  }

  static int _readInt(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  static bool _readBool(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is bool) {
      return value;
    }
    return false;
  }

  static DateTime? _readNullableDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    return null;
  }
}
