import 'package:cloud_firestore/cloud_firestore.dart';

class ChatDto {
  final String id;
  final String bookingId;
  final List<String> participants;
  final DateTime lastMessageAt;
  final String lastMessage;
  final String lastMessageType;
  final String lastMessageSenderId;

  const ChatDto({
    required this.id,
    required this.bookingId,
    required this.participants,
    required this.lastMessageAt,
    this.lastMessage = '',
    this.lastMessageType = 'text',
    this.lastMessageSenderId = '',
  });

  factory ChatDto.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return ChatDto(
      id: doc.id,
      bookingId: _readString(data, 'bookingId'),
      participants: _readStringList(data['participants']),
      lastMessageAt: _readDateTime(data['lastMessageAt']),
      lastMessage: _readString(data, 'lastMessage'),
      lastMessageType: _readString(data, 'lastMessageType', fallback: 'text'),
      lastMessageSenderId: _readString(data, 'lastMessageSenderId'),
    );
  }

  factory ChatDto.fromJson(Map<String, dynamic> json) {
    return ChatDto(
      id: json['id'] as String,
      bookingId: json['bookingId'] as String,
      participants: (json['participants'] as List<dynamic>).cast<String>(),
      lastMessageAt: DateTime.parse(json['lastMessageAt']),
      lastMessage: json['lastMessage'] as String? ?? '',
      lastMessageType: json['lastMessageType'] as String? ?? 'text',
      lastMessageSenderId: json['lastMessageSenderId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bookingId': bookingId,
      'participants': participants,
      'lastMessageAt': Timestamp.fromDate(lastMessageAt),
      'lastMessage': lastMessage,
      'lastMessageType': lastMessageType,
      'lastMessageSenderId': lastMessageSenderId,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookingId': bookingId,
      'participants': participants,
      'lastMessageAt': lastMessageAt.toIso8601String(),
      'lastMessage': lastMessage,
      'lastMessageType': lastMessageType,
      'lastMessageSenderId': lastMessageSenderId,
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

  factory ChatMessageDto.fromJson(Map<String, dynamic> json) {
    return ChatMessageDto(
      id: json['id'] as String,
      chatId: json['chatId'] as String,
      senderId: json['senderId'] as String,
      type: json['type'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt']),
      seenBy: (json['seenBy'] as List<dynamic>?)?.cast<String>() ?? [],
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chatId': chatId,
      'senderId': senderId,
      'type': type,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
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
