import 'package:flutter_test/flutter_test.dart';
import 'package:laqta/features/chat/data/dtos/chat_dto.dart';

void main() {
  group('ChatDto', () {
    test('fromJson reads direct chat preview and other user metadata', () {
      final lastSeen = DateTime.utc(2026, 6, 1, 8);
      final chat = ChatDto.fromJson({
        'id': 'chat1',
        'bookingId': 'booking1',
        'participants': ['customer1', 'photographer1'],
        'lastMessageAt': '2026-06-01T09:00:00.000Z',
        'lastMessage': 'Hello',
        'lastMessageType': 'text',
        'lastMessageSenderId': 'customer1',
        'unreadCount': 2.0,
        'otherUser': {
          'name': 'Photographer',
          'photoUrl': 'https://cdn.example/avatar.jpg',
          'lastSeen': lastSeen.toIso8601String(),
        },
      });

      expect(chat.id, 'chat1');
      expect(chat.participants, ['customer1', 'photographer1']);
      expect(chat.lastMessage, 'Hello');
      expect(chat.unreadCount, 2);
      expect(chat.otherUserName, 'Photographer');
      expect(chat.otherUserImage, 'https://cdn.example/avatar.jpg');
      expect(chat.otherUserLastSeen, isNotNull);
    });

    test('fromJson defaults optional preview fields safely', () {
      final chat = ChatDto.fromJson({
        'id': 'chat2',
        'bookingId': 'booking2',
        'participants': ['u1'],
        'lastMessageAt': '2026-06-01T09:00:00.000Z',
      });

      expect(chat.lastMessage, isEmpty);
      expect(chat.lastMessageType, 'text');
      expect(chat.lastMessageSenderId, isEmpty);
      expect(chat.unreadCount, 0);
      expect(chat.otherUserName, isEmpty);
      expect(chat.otherUserImage, isEmpty);
      expect(chat.otherUserLastSeen, isNull);
    });

    test(
      'toJson serializes chat preview without leaking derived otherUser data',
      () {
        final lastMessageAt = DateTime.utc(2026, 6, 1, 9);
        final chat = ChatDto(
          id: 'chat3',
          bookingId: 'booking3',
          participants: const ['u1', 'u2'],
          lastMessageAt: lastMessageAt,
          lastMessage: 'Latest',
          lastMessageType: 'image',
          lastMessageSenderId: 'u2',
          unreadCount: 5,
          otherUserName: 'Ignored',
        );

        final json = chat.toJson();

        expect(json['id'], 'chat3');
        expect(json['participants'], ['u1', 'u2']);
        expect(json['lastMessageAt'], lastMessageAt.toIso8601String());
        expect(json['lastMessageType'], 'image');
        expect(json['unreadCount'], 5);
        expect(json.containsKey('otherUserName'), isFalse);
      },
    );
  });

  group('ChatMessageDto', () {
    test('fromJson reads media message fields and seenBy values', () {
      final message = ChatMessageDto.fromJson({
        'id': 'm1',
        'chatId': 'chat1',
        'senderId': 'u1',
        'type': 'image',
        'content': 'https://cdn.example/image.jpg',
        'mediaId': 'media1',
        'fileName': 'image.jpg',
        'fileSize': 12345,
        'createdAt': '2026-06-01T09:00:00.000Z',
        'seenBy': ['u2'],
      });

      expect(message.type, 'image');
      expect(message.mediaId, 'media1');
      expect(message.fileName, 'image.jpg');
      expect(message.fileSize, 12345);
      expect(message.seenBy, ['u2']);
    });

    test('toJson preserves document metadata for backend persistence', () {
      final createdAt = DateTime.utc(2026, 6, 1, 9);
      final message = ChatMessageDto(
        id: 'm2',
        chatId: 'chat2',
        senderId: 'u1',
        type: 'document',
        content: 'contract.pdf',
        mediaId: 'media2',
        fileName: 'contract.pdf',
        fileSize: 2048,
        createdAt: createdAt,
        seenBy: const ['u1', 'u2'],
      );

      final json = message.toJson();

      expect(json['id'], 'm2');
      expect(json['type'], 'document');
      expect(json['mediaId'], 'media2');
      expect(json['fileName'], 'contract.pdf');
      expect(json['fileSize'], 2048);
      expect(json['createdAt'], createdAt.toIso8601String());
      expect(json['seenBy'], ['u1', 'u2']);
    });

    test('fromJson defaults seenBy to an empty list when omitted', () {
      final message = ChatMessageDto.fromJson({
        'id': 'm3',
        'chatId': 'chat3',
        'senderId': 'u1',
        'type': 'text',
        'content': 'Hi',
        'createdAt': '2026-06-01T09:00:00.000Z',
      });

      expect(message.seenBy, isEmpty);
      expect(message.mediaId, isNull);
      expect(message.fileName, isNull);
      expect(message.fileSize, isNull);
    });
  });
}
