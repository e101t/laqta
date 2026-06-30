class FavoriteDto {
  final String userId;
  final String photographerId;

  const FavoriteDto({required this.userId, required this.photographerId});

  factory FavoriteDto.fromJson(Map<String, dynamic> json) {
    return FavoriteDto(
      userId: _readString(json, 'userId'),
      photographerId: _readString(json, 'photographerId'),
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
}
