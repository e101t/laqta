import 'package:cloud_firestore/cloud_firestore.dart';

class FavoriteDto {
  final String userId;
  final String photographerId;

  const FavoriteDto({required this.userId, required this.photographerId});

  factory FavoriteDto.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return FavoriteDto(
      userId: _readString(data, 'userId'),
      photographerId: _readString(data, 'photographerId'),
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
}
