import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String id;
  final String bookingId;
  final List<String> participants; // [customerId, photographerId]
  final DateTime lastMessageAt;

  ChatModel({
    required this.id,
    required this.bookingId,
    required this.participants,
    required this.lastMessageAt,
  });

  factory ChatModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatModel(
      id: doc.id,
      bookingId: data['bookingId'] ?? '',
      participants: List<String>.from(data['participants'] ?? []),
      lastMessageAt:
          (data['lastMessageAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'bookingId': bookingId,
      'participants': participants,
      'lastMessageAt': Timestamp.fromDate(lastMessageAt),
    };
  }
}

class MessageModel {
  final String id;
  final String chatId;
  final String senderId;
  final String type; // text, image, video, location
  final String content;
  final DateTime createdAt;
  final List<String> seenBy;

  MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.type,
    required this.content,
    required this.createdAt,
    this.seenBy = const [],
  });

  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MessageModel(
      id: doc.id,
      chatId: data['chatId'] ?? '',
      senderId: data['senderId'] ?? '',
      type: data['type'] ?? 'text',
      content: data['content'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      seenBy: List<String>.from(data['seenBy'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'chatId': chatId,
      'senderId': senderId,
      'type': type,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      'seenBy': seenBy,
    };
  }

  bool isSeenBy(String userId) => seenBy.contains(userId);

  MessageModel copyWith({List<String>? seenBy}) {
    return MessageModel(
      id: id,
      chatId: chatId,
      senderId: senderId,
      type: type,
      content: content,
      createdAt: createdAt,
      seenBy: seenBy ?? this.seenBy,
    );
  }
}
