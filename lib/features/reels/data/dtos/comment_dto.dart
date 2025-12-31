import 'package:cloud_firestore/cloud_firestore.dart';

class CommentDto {
  final String id;
  final String reelId;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final String text;
  final DateTime createdAt;
  final int likes;

  const CommentDto({
    required this.id,
    required this.reelId,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.text,
    required this.createdAt,
    required this.likes,
  });

  factory CommentDto.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return CommentDto(
      id: doc.id,
      reelId: _readString(data, 'reelId'),
      userId: _readString(data, 'userId'),
      userName: _readString(data, 'userName', fallback: 'Unknown User'),
      userPhotoUrl: _readNullableString(data, 'userPhotoUrl'),
      text: _readString(data, 'text'),
      createdAt: _readDateTime(data['createdAt']),
      likes: _readInt(data, 'likes'),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'reelId': reelId,
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'text': text,
      'createdAt': Timestamp.fromDate(createdAt),
      'likes': likes,
    };
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

  static String? _readNullableString(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is String) {
      return value;
    }
    return null;
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

  static DateTime _readDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    return DateTime.now();
  }
}
