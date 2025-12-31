import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:luqta/core/utils/firestore_parsers.dart';

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
    final data = firestoreMap(doc.data());
    return ChatModel(
      id: doc.id,
      bookingId: readString(data, 'bookingId'),
      participants: readStringList(data, 'participants'),
      lastMessageAt: readDateTime(data, 'lastMessageAt'),
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
    final data = firestoreMap(doc.data());
    return MessageModel(
      id: doc.id,
      chatId: readString(data, 'chatId'),
      senderId: readString(data, 'senderId'),
      type: readString(data, 'type', defaultValue: 'text'),
      content: readString(data, 'content'),
      createdAt: readDateTime(data, 'createdAt'),
      seenBy: readStringList(data, 'seenBy'),
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
