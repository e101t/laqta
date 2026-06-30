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

  factory UserAchievementDto.fromJson(Map<String, dynamic> json) {
    return UserAchievementDto(
      id: _readString(json, 'id'),
      userId: _readString(json, 'userId'),
      achievementId: _readString(json, 'achievementId'),
      currentProgress: _readInt(json, 'currentProgress'),
      isUnlocked: _readBool(json, 'isUnlocked'),
      unlockedAt: _readNullableDateTime(json['unlockedAt']),
    );
  }

  static String _readString(
    Map<String, dynamic> data,
    String key, {
    String fallback = '',
  }) {
    final value = data[key];
    return value is String ? value : fallback;
  }

  static int _readInt(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static bool _readBool(Map<String, dynamic> data, String key) {
    final value = data[key];
    return value is bool ? value : false;
  }

  static DateTime? _readNullableDateTime(dynamic value) {
    if (value is String) return DateTime.tryParse(value);
    if (value is DateTime) return value;
    return null;
  }
}
