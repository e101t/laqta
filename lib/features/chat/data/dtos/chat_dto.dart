import 'package:cloud_firestore/cloud_firestore.dart';

class ChatDto {
  final String id;
  final String bookingId;
  final List<String> participants;
  final DateTime lastMessageAt;

  const ChatDto({
    required this.id,
    required this.bookingId,
    required this.participants,
    required this.lastMessageAt,
  });

  factory ChatDto.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return ChatDto(
      id: doc.id,
      bookingId: _readString(data, 'bookingId'),
      participants: _readStringList(data['participants']),
      lastMessageAt: _readDateTime(data['lastMessageAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bookingId': bookingId,
      'participants': participants,
      'lastMessageAt': Timestamp.fromDate(lastMessageAt),
    };
  }

  static String _readString(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is String) {
      return value;
    }
    return '';
  }

  static List<String> _readStringList(dynamic value) {
    if (value is List) {
      return value.whereType<String>().toList();
    }
    return <String>[];
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

class ChatMessageDto {
  final String id;
  final String chatId;
  final String senderId;
  final String type; // text, image, video, document
  final String content;
  final DateTime createdAt;
  final List<String> seenBy;

  const ChatMessageDto({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.type,
    required this.content,
    required this.createdAt,
    this.seenBy = const [],
  });

  factory ChatMessageDto.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return ChatMessageDto(
      id: doc.id,
      chatId: _readString(data, 'chatId'),
      senderId: _readString(data, 'senderId'),
      type: _readString(data, 'type', fallback: 'text'),
      content: _readString(data, 'content'),
      createdAt: ChatDto._readDateTime(data['createdAt']),
      seenBy: ChatDto._readStringList(data['seenBy']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'chatId': chatId,
      'senderId': senderId,
      'type': type,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      'seenBy': seenBy,
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
}
