import 'package:flutter_test/flutter_test.dart';
import 'package:laqta/core/services/backend_media_service.dart';
import 'package:laqta/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:laqta/features/chat/data/dtos/chat_dto.dart';
import 'package:laqta/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:laqta/features/chat/domain/entities/chat_message.dart';

class _FakeChatRemoteDataSource implements ChatRemoteDataSource {
  final List<ChatDto> chats;
  final Map<String, Map<String, dynamic>?> publicUserDataById;
  final Map<String, ChatMessageDto?> lastMessageByChatId;
  final Map<String, List<ChatMessageDto>> otherMessagesByChatId;
  final Map<String, List<ChatMessageDto>> messagesByChatId;

  int getLastMessageCalls = 0;
  int getMessagesFromOtherUserCalls = 0;
  int getPublicUserDataCalls = 0;
  int getPublicUsersDataCalls = 0;
  int markMessagesSeenCalls = 0;
  int sendMessageCalls = 0;
  int updateChatPreviewCalls = 0;
  List<ChatMessageDto> lastMarkedMessages = const [];
  ChatMessageDto? lastSentMessage;
  ({
    String chatId,
    DateTime timestamp,
    String lastMessage,
    String lastMessageType,
    String senderId,
  })?
  lastPreviewUpdate;

  _FakeChatRemoteDataSource({
    required this.chats,
    required this.publicUserDataById,
    this.lastMessageByChatId = const {},
    this.otherMessagesByChatId = const {},
    this.messagesByChatId = const {},
  });

  @override
  String createMessageId(String chatId) => 'msg_1';

  @override
  Future<ChatDto> createChat({
    required String bookingId,
    required List<String> participants,
    required DateTime lastMessageAt,
    String lastMessage = '',
    String lastMessageType = 'text',
    String lastMessageSenderId = '',
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<ChatDto> createDirectChat({required String participantId}) async {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteChat(String chatId) async => throw UnimplementedError();

  @override
  Future<void> deleteChatWithMessages(String chatId) async =>
      throw UnimplementedError();

  @override
  Future<ChatDto?> getChatByBookingId(String bookingId) async =>
      throw UnimplementedError();

  @override
  Future<ChatDto> getChatById(String chatId) async =>
      throw UnimplementedError();

  @override
  Future<List<ChatDto>> getChatsForUser(String userId) async => chats;

  @override
  Future<List<ChatMessageDto>> getMessages(String chatId) async =>
      messagesByChatId[chatId] ?? const <ChatMessageDto>[];

  @override
  Future<List<ChatMessageDto>> getMessagesFromOtherUser(
    String chatId,
    String currentUserId,
  ) async {
    getMessagesFromOtherUserCalls++;
    return otherMessagesByChatId[chatId] ?? const <ChatMessageDto>[];
  }

  @override
  Future<ChatMessageDto?> getLastMessage(String chatId) async {
    getLastMessageCalls++;
    return lastMessageByChatId[chatId];
  }

  @override
  Future<Map<String, dynamic>?> getPublicUserData(String userId) async {
    getPublicUserDataCalls++;
    return publicUserDataById[userId];
  }

  @override
  Future<Map<String, Map<String, dynamic>>> getPublicUsersData(
    List<String> userIds,
  ) async {
    getPublicUsersDataCalls++;
    return {
      for (final userId in userIds)
        if (publicUserDataById[userId] != null)
          userId: publicUserDataById[userId]!,
    };
  }

  @override
  Future<Map<String, dynamic>?> getUserData(String userId) async =>
      throw UnimplementedError();

  @override
  Future<void> sendMessage(ChatMessageDto message) async {
    sendMessageCalls++;
    lastSentMessage = message;
  }

  @override
  Future<void> markMessagesSeen({
    required String chatId,
    required List<ChatMessageDto> messages,
  }) async {
    markMessagesSeenCalls++;
    lastMarkedMessages = messages;
  }

  @override
  Future<void> updateChatPreview({
    required String chatId,
    required DateTime timestamp,
    required String lastMessage,
    required String lastMessageType,
    required String senderId,
  }) async {
    updateChatPreviewCalls++;
    lastPreviewUpdate = (
      chatId: chatId,
      timestamp: timestamp,
      lastMessage: lastMessage,
      lastMessageType: lastMessageType,
      senderId: senderId,
    );
  }

  @override
  Future<void> updateUserBlockedList(
    String userId,
    List<String> blockedUsers,
  ) async => throw UnimplementedError();
}

class _FakeBackendMediaService extends BackendMediaService {
  _FakeBackendMediaService(this.uploadedUrl, {String? mediaId})
    : uploadedMediaId = mediaId ?? 'media-test-1';

  final String uploadedUrl;
  final String uploadedMediaId;
  ({
    String entityType,
    String entityId,
    String filePath,
    bool publicContent,
    String? fileName,
  })?
  lastUpload;

  @override
  Future<BackendMediaUploadResult> uploadFileReference({
    required String entityType,
    required String entityId,
    required String filePath,
    required bool publicContent,
    String? fileName,
  }) async {
    lastUpload = (
      entityType: entityType,
      entityId: entityId,
      filePath: filePath,
      publicContent: publicContent,
      fileName: fileName,
    );
    return BackendMediaUploadResult(
      mediaId: uploadedMediaId,
      stableUrl: uploadedUrl,
    );
  }
}

void main() {
  group('ChatRepositoryImpl.getChatThreads', () {
    test(
      'uses cached chat preview without fetching the last message again',
      () async {
        final remote = _FakeChatRemoteDataSource(
          chats: [
            ChatDto(
              id: 'chat_1',
              bookingId: 'booking_1',
              participants: const ['user_1', 'user_2'],
              lastMessageAt: DateTime(2026, 4, 8, 10),
              lastMessage: 'Hello from preview',
              lastMessageType: 'text',
              lastMessageSenderId: 'user_2',
            ),
          ],
          publicUserDataById: {
            'user_2': {
              'name': 'Other User',
              'photoUrl': 'https://example.com/user.jpg',
            },
          },
          otherMessagesByChatId: {
            'chat_1': [
              ChatMessageDto(
                id: 'msg_1',
                chatId: 'chat_1',
                senderId: 'user_2',
                type: 'text',
                content: 'Hello from preview',
                createdAt: DateTime(2026, 4, 8, 10),
                seenBy: const [],
              ),
            ],
          },
        );
        final repository = ChatRepositoryImpl(remote);

        final result = await repository.getChatThreads(userId: 'user_1');

        expect(result.isSuccess, isTrue);
        expect(remote.getLastMessageCalls, 0);
        expect(remote.getMessagesFromOtherUserCalls, 1);
        expect(remote.getPublicUsersDataCalls, 1);
        expect(remote.getPublicUserDataCalls, 0);
        expect(result.valueOrNull, isNotNull);
        expect(result.valueOrNull!.single.lastMessage, 'Hello from preview');
      },
    );

    test(
      'skips unread query when the latest preview belongs to the current user',
      () async {
        final remote = _FakeChatRemoteDataSource(
          chats: [
            ChatDto(
              id: 'chat_2',
              bookingId: 'booking_2',
              participants: const ['user_1', 'user_3'],
              lastMessageAt: DateTime(2026, 4, 8, 11),
              lastMessage: 'Sent by me',
              lastMessageType: 'text',
              lastMessageSenderId: 'user_1',
            ),
          ],
          publicUserDataById: {
            'user_3': {
              'name': 'Photographer',
              'photoUrl': 'https://example.com/photo.jpg',
            },
          },
        );
        final repository = ChatRepositoryImpl(remote);

        final result = await repository.getChatThreads(userId: 'user_1');

        expect(result.isSuccess, isTrue);
        expect(remote.getLastMessageCalls, 0);
        expect(remote.getMessagesFromOtherUserCalls, 0);
        expect(remote.getPublicUsersDataCalls, 1);
        expect(remote.getPublicUserDataCalls, 0);
        expect(result.valueOrNull, isNotNull);
        expect(result.valueOrNull!.single.unreadCount, 0);
      },
    );

    test(
      'falls back to the latest message query when cached preview is missing',
      () async {
        final remote = _FakeChatRemoteDataSource(
          chats: [
            ChatDto(
              id: 'chat_3',
              bookingId: 'booking_3',
              participants: const ['user_1', 'user_4'],
              lastMessageAt: DateTime(2026, 4, 8, 9),
            ),
          ],
          publicUserDataById: {
            'user_4': {'name': 'Client', 'photoUrl': ''},
          },
          lastMessageByChatId: {
            'chat_3': ChatMessageDto(
              id: 'msg_3',
              chatId: 'chat_3',
              senderId: 'user_4',
              type: 'text',
              content: 'Fallback message',
              createdAt: DateTime(2026, 4, 8, 12),
              seenBy: const [],
            ),
          },
          otherMessagesByChatId: {
            'chat_3': [
              ChatMessageDto(
                id: 'msg_3',
                chatId: 'chat_3',
                senderId: 'user_4',
                type: 'text',
                content: 'Fallback message',
                createdAt: DateTime(2026, 4, 8, 12),
                seenBy: const [],
              ),
            ],
          },
        );
        final repository = ChatRepositoryImpl(remote);

        final result = await repository.getChatThreads(userId: 'user_1');

        expect(result.isSuccess, isTrue);
        expect(remote.getLastMessageCalls, 1);
        expect(remote.getPublicUsersDataCalls, 1);
        expect(remote.getPublicUserDataCalls, 0);
        expect(result.valueOrNull, isNotNull);
        expect(result.valueOrNull!.single.lastMessage, 'Fallback message');
      },
    );

    test(
      'loads public user data in one batched call for multiple chats',
      () async {
        final remote = _FakeChatRemoteDataSource(
          chats: [
            ChatDto(
              id: 'chat_4',
              bookingId: 'booking_4',
              participants: const ['user_1', 'user_2'],
              lastMessageAt: DateTime(2026, 4, 8, 10),
              lastMessage: 'Hi',
              lastMessageType: 'text',
              lastMessageSenderId: 'user_2',
            ),
            ChatDto(
              id: 'chat_5',
              bookingId: 'booking_5',
              participants: const ['user_1', 'user_3'],
              lastMessageAt: DateTime(2026, 4, 8, 11),
              lastMessage: 'Hello',
              lastMessageType: 'text',
              lastMessageSenderId: 'user_3',
            ),
          ],
          publicUserDataById: {
            'user_2': {
              'name': 'Second User',
              'photoUrl': 'https://example.com/2.jpg',
            },
            'user_3': {
              'name': 'Third User',
              'photoUrl': 'https://example.com/3.jpg',
            },
          },
          otherMessagesByChatId: {
            'chat_4': [
              ChatMessageDto(
                id: 'msg_4',
                chatId: 'chat_4',
                senderId: 'user_2',
                type: 'text',
                content: 'Hi',
                createdAt: DateTime(2026, 4, 8, 10),
                seenBy: const [],
              ),
            ],
            'chat_5': [
              ChatMessageDto(
                id: 'msg_5',
                chatId: 'chat_5',
                senderId: 'user_3',
                type: 'text',
                content: 'Hello',
                createdAt: DateTime(2026, 4, 8, 11),
                seenBy: const [],
              ),
            ],
          },
        );
        final repository = ChatRepositoryImpl(remote);

        final result = await repository.getChatThreads(userId: 'user_1');

        expect(result.isSuccess, isTrue);
        expect(result.valueOrNull, hasLength(2));
        expect(remote.getPublicUsersDataCalls, 1);
        expect(remote.getPublicUserDataCalls, 0);
      },
    );
  });

  group('ChatRepositoryImpl.markMessagesRead', () {
    test('marks only unseen incoming messages as read', () async {
      final remote = _FakeChatRemoteDataSource(
        chats: const [],
        publicUserDataById: const {},
      );
      final repository = ChatRepositoryImpl(remote);

      final result = await repository.markMessagesRead(
        chatId: 'chat_6',
        userId: 'user_1',
        messages: [
          ChatMessage(
            id: 'msg_seen',
            chatId: 'chat_6',
            senderId: 'user_2',
            type: 'text',
            content: 'Seen already',
            createdAt: DateTime(2026, 4, 8, 12),
            seenBy: ['user_1'],
          ),
          ChatMessage(
            id: 'msg_unread',
            chatId: 'chat_6',
            senderId: 'user_2',
            type: 'text',
            content: 'Unread',
            createdAt: DateTime(2026, 4, 8, 13),
            seenBy: [],
          ),
          ChatMessage(
            id: 'msg_mine',
            chatId: 'chat_6',
            senderId: 'user_1',
            type: 'text',
            content: 'Mine',
            createdAt: DateTime(2026, 4, 8, 14),
            seenBy: [],
          ),
        ],
      );

      expect(result.isSuccess, isTrue);
      expect(remote.markMessagesSeenCalls, 1);
      expect(remote.lastMarkedMessages, hasLength(1));
      expect(remote.lastMarkedMessages.single.id, 'msg_unread');
      expect(remote.lastMarkedMessages.single.seenBy, ['user_1']);
    });

    test(
      'does not write when every incoming message is already read',
      () async {
        final remote = _FakeChatRemoteDataSource(
          chats: const [],
          publicUserDataById: const {},
        );
        final repository = ChatRepositoryImpl(remote);

        final result = await repository.markMessagesRead(
          chatId: 'chat_7',
          userId: 'user_1',
          messages: [
            ChatMessage(
              id: 'msg_seen',
              chatId: 'chat_7',
              senderId: 'user_2',
              type: 'text',
              content: 'Seen already',
              createdAt: DateTime(2026, 4, 8, 15),
              seenBy: ['user_1'],
            ),
          ],
        );

        expect(result.isSuccess, isTrue);
        expect(remote.markMessagesSeenCalls, 0);
      },
    );

    test('loads messages remotely when no message list is provided', () async {
      final remote = _FakeChatRemoteDataSource(
        chats: const [],
        publicUserDataById: const {},
        messagesByChatId: {
          'chat_8': [
            ChatMessageDto(
              id: 'msg_remote',
              chatId: 'chat_8',
              senderId: 'user_2',
              type: 'text',
              content: 'Remote unread',
              createdAt: DateTime(2026, 4, 8, 16),
              seenBy: const [],
            ),
          ],
        },
      );
      final repository = ChatRepositoryImpl(remote);

      final result = await repository.markMessagesRead(
        chatId: 'chat_8',
        userId: 'user_1',
      );

      expect(result.isSuccess, isTrue);
      expect(remote.markMessagesSeenCalls, 1);
      expect(remote.lastMarkedMessages.single.id, 'msg_remote');
      expect(remote.lastMarkedMessages.single.seenBy, ['user_1']);
    });
  });

  group('ChatRepositoryImpl.sendMediaMessage', () {
    test(
      'uploads chat images through backend media and persists a structured media reference',
      () async {
        final remote = _FakeChatRemoteDataSource(
          chats: const [],
          publicUserDataById: const {},
        );
        final mediaService = _FakeBackendMediaService(
          'https://api.laqta.cloud/api/v1/media/media-image-1',
          mediaId: 'media-image-1',
        );
        final repository = ChatRepositoryImpl(
          remote,
          mediaService: mediaService,
        );

        final result = await repository.sendMediaMessage(
          chatId: 'chat_9',
          senderId: 'user_1',
          type: 'image',
          filePath: 'C:/tmp/photo.jpg',
          messageId: 'msg_image',
        );

        expect(result.isSuccess, isTrue);
        expect(mediaService.lastUpload, isNotNull);
        expect(mediaService.lastUpload!.entityType, 'chat');
        expect(mediaService.lastUpload!.entityId, 'chat_9');
        expect(mediaService.lastUpload!.publicContent, isFalse);
        expect(remote.sendMessageCalls, 1);
        expect(remote.lastSentMessage?.content, isEmpty);
        expect(remote.lastSentMessage?.mediaId, 'media-image-1');
        expect(remote.updateChatPreviewCalls, 1);
        expect(remote.lastPreviewUpdate?.lastMessageType, 'image');
        expect(remote.lastPreviewUpdate?.lastMessage, 'Image');
      },
    );

    test(
      'stores backend media ids inside document messages with file metadata',
      () async {
        final remote = _FakeChatRemoteDataSource(
          chats: const [],
          publicUserDataById: const {},
        );
        final mediaService = _FakeBackendMediaService(
          'https://api.laqta.cloud/api/v1/media/media-doc-1',
          mediaId: 'media-doc-1',
        );
        final repository = ChatRepositoryImpl(
          remote,
          mediaService: mediaService,
        );

        final result = await repository.sendMediaMessage(
          chatId: 'chat_10',
          senderId: 'user_1',
          type: 'document',
          filePath: 'C:/tmp/brief.pdf',
          messageId: 'msg_doc',
          fileName: 'brief.pdf',
          fileSize: 4096,
        );

        expect(result.isSuccess, isTrue);
        expect(mediaService.lastUpload?.fileName, 'brief.pdf');
        expect(remote.lastSentMessage?.content, isEmpty);
        expect(remote.lastSentMessage?.mediaId, 'media-doc-1');
        expect(remote.lastSentMessage?.fileName, 'brief.pdf');
        expect(remote.lastSentMessage?.fileSize, 4096);
        expect(remote.lastPreviewUpdate?.lastMessageType, 'document');
        expect(remote.lastPreviewUpdate?.lastMessage, 'brief.pdf');
      },
    );
  });
}
