import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationDto {
  final String id;
  final String userId;
  final String title;
  final String body;
  final String type;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime createdAt;
  final String? imageUrl;
  final String? actionUrl;

  const NotificationDto({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.data,
    required this.isRead,
    required this.createdAt,
    this.imageUrl,
    this.actionUrl,
  });

  factory NotificationDto.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return NotificationDto(
      id: doc.id,
      userId: _readString(data, 'userId'),
      title: _readString(data, 'title'),
      body: _readString(data, 'body'),
      type: _readString(data, 'type', fallback: 'system'),
      data: _readMapOrNull(data['data']),
      isRead: _readBool(data, 'isRead'),
      createdAt: _readDateTime(data['createdAt']),
      imageUrl: _readNullableString(data, 'imageUrl'),
      actionUrl: _readNullableString(data, 'actionUrl'),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'body': body,
      'type': type,
      'data': data,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
      'imageUrl': imageUrl,
      'actionUrl': actionUrl,
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

  static bool _readBool(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is bool) {
      return value;
    }
    return false;
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

  static Map<String, dynamic>? _readMapOrNull(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return null;
  }
}
