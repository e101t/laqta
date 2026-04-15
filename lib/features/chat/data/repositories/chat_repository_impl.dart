import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laqta/core/domain/failures/failure.dart';
import 'package:laqta/core/domain/result/result.dart';
import 'package:laqta/core/services/backend_media_service.dart';
import 'package:laqta/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:laqta/features/chat/data/dtos/chat_dto.dart';
import 'package:laqta/features/chat/data/mappers/chat_mapper.dart';
import 'package:laqta/features/chat/domain/entities/chat_message.dart';
import 'package:laqta/features/chat/domain/entities/chat_thread.dart';
import 'package:laqta/features/chat/domain/entities/chat_thread_preview.dart';
import 'package:laqta/features/chat/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource _remoteDataSource;
  final BackendMediaService _mediaService;

  ChatRepositoryImpl(
    this._remoteDataSource, {
    BackendMediaService? mediaService,
  }) : _mediaService = mediaService ?? BackendMediaService();

  @override
  String createMessageId({required String chatId}) {
    return _remoteDataSource.createMessageId(chatId);
  }

  @override
  Future<Result<List<ChatThreadPreview>>> getChatThreads({
    required String userId,
  }) async {
    try {
      final chats = await _remoteDataSource.getChatsForUser(userId);
      final otherUserIds = chats
          .map(
            (chat) => chat.participants.firstWhere(
              (id) => id != userId,
              orElse: () => '',
            ),
          )
          .where((id) => id.isNotEmpty)
          .toSet()
          .toList();
      final publicUsersData = await _remoteDataSource.getPublicUsersData(
        otherUserIds,
      );
      final previews = await Future.wait(
        chats.map(
          (chat) => _buildChatThreadPreview(
            chat: chat,
            userId: userId,
            publicUsersData: publicUsersData,
          ),
        ),
      );

      final sorted = previews.whereType<ChatThreadPreview>().toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return Result.success(sorted);
    } catch (e) {
      return Result.failure(
        Failure(message: 'Failed to load chats', code: e.toString()),
      );
    }
  }

  @override
  Future<Result<List<ChatMessage>>> getMessages({
    required String chatId,
  }) async {
    try {
      final messages = await _remoteDataSource.getMessages(chatId);
      return Result.success(messages.map(ChatMapper.toDomain).toList());
    } catch (e) {
      return Result.failure(
        Failure(message: 'Failed to load messages', code: e.toString()),
      );
    }
  }

  @override
  Future<Result<void>> markMessagesRead({
    required String chatId,
    required String userId,
    List<ChatMessage>? messages,
  }) async {
    try {
      final sourceMessages =
          messages ??
          (await _remoteDataSource.getMessages(
            chatId,
          )).map(ChatMapper.toDomain).toList();
      final unreadIncoming = sourceMessages.where((message) {
        return message.senderId != userId && !message.seenBy.contains(userId);
      }).toList();

      if (unreadIncoming.isEmpty) {
        return Result.success(null);
      }

      final updatedDtos = unreadIncoming.map((message) {
        final seenBy = {...message.seenBy, userId}.toList();
        return ChatMapper.toDto(message.copyWith(seenBy: seenBy));
      }).toList();

      await _remoteDataSource.markMessagesSeen(
        chatId: chatId,
        messages: updatedDtos,
      );
      return Result.success(null);
    } catch (e) {
      return Result.failure(
        Failure(message: 'Failed to mark messages as read', code: e.toString()),
      );
    }
  }

  @override
  Future<Result<void>> sendMessage(ChatMessage message) async {
    try {
      final dto = ChatMapper.toDto(message);
      await _remoteDataSource.sendMessage(dto);
      await _remoteDataSource.updateChatPreview(
        chatId: message.chatId,
        timestamp: message.createdAt,
        lastMessage: _buildPreviewContentFromMessage(
          type: message.type,
          content: message.content,
        ),
        lastMessageType: message.type,
        senderId: message.senderId,
      );
      return Result.success(null);
    } catch (e) {
      return Result.failure(
        Failure(message: 'Failed to send message', code: e.toString()),
      );
    }
  }

  @override
  Future<Result<ChatMessage>> sendMediaMessage({
    required String chatId,
    required String senderId,
    required String type,
    required String filePath,
    required String messageId,
    String? fileName,
    int? fileSize,
  }) async {
    try {
      final downloadUrl = await _mediaService.uploadFile(
        entityType: 'chat',
        entityId: chatId,
        filePath: filePath,
        publicContent: false,
        fileName: fileName,
      );

      final content = type == 'document'
          ? '$downloadUrl|${fileName ?? 'Document'}|${fileSize ?? 0}'
          : downloadUrl;

      final message = ChatMessage(
        id: messageId,
        chatId: chatId,
        senderId: senderId,
        type: type,
        content: content,
        createdAt: DateTime.now(),
      );

      await _remoteDataSource.sendMessage(ChatMapper.toDto(message));
      await _remoteDataSource.updateChatPreview(
        chatId: chatId,
        timestamp: message.createdAt,
        lastMessage: _buildPreviewContentFromMessage(
          type: type,
          content: content,
        ),
        lastMessageType: type,
        senderId: senderId,
      );

      return Result.success(message);
    } catch (e) {
      return Result.failure(
        Failure(message: 'Failed to send media message', code: e.toString()),
      );
    }
  }

  @override
  Future<Result<void>> deleteChat({required String chatId}) async {
    try {
      await _remoteDataSource.deleteChat(chatId);
      return Result.success(null);
    } catch (e) {
      return Result.failure(
        Failure(message: 'Failed to delete chat', code: e.toString()),
      );
    }
  }

  @override
  Future<Result<void>> deleteChatWithMessages({required String chatId}) async {
    try {
      await _remoteDataSource.deleteChatWithMessages(chatId);
      return Result.success(null);
    } catch (e) {
      return Result.failure(
        Failure(message: 'Failed to delete chat', code: e.toString()),
      );
    }
  }

  @override
  Future<Result<bool>> toggleBlockUser({
    required String chatId,
    required String currentUserId,
  }) async {
    try {
      final chat = await _remoteDataSource.getChatById(chatId);
      final otherUserId = chat.participants.firstWhere(
        (id) => id != currentUserId,
        orElse: () => '',
      );
      if (otherUserId.isEmpty) {
        return Result.failure(
          const Failure(message: 'Unable to determine user'),
        );
      }

      final userData = await _remoteDataSource.getUserData(currentUserId);
      if (userData == null) {
        return Result.failure(const Failure(message: 'User not found'));
      }

      final blockedUsers = _readStringList(userData['blockedUsers']);
      final isBlocked = blockedUsers.contains(otherUserId);
      if (isBlocked) {
        blockedUsers.remove(otherUserId);
      } else {
        blockedUsers.add(otherUserId);
      }

      await _remoteDataSource.updateUserBlockedList(
        currentUserId,
        blockedUsers,
      );

      return Result.success(!isBlocked);
    } catch (e) {
      return Result.failure(
        Failure(message: 'Failed to update block list', code: e.toString()),
      );
    }
  }

  @override
  Future<Result<String?>> getOtherParticipantId({
    required String chatId,
    required String currentUserId,
  }) async {
    try {
      final chat = await _remoteDataSource.getChatById(chatId);
      final otherUserId = chat.participants.firstWhere(
        (id) => id != currentUserId,
        orElse: () => '',
      );
      if (otherUserId.isEmpty) {
        return Result.success(null);
      }
      return Result.success(otherUserId);
    } catch (e) {
      return Result.failure(
        Failure(message: 'Failed to load participant', code: e.toString()),
      );
    }
  }

  @override
  Future<Result<ChatThread>> getOrCreateChatForBooking({
    required String bookingId,
    required List<String> participants,
  }) async {
    try {
      final existing = await _remoteDataSource.getChatByBookingId(bookingId);
      final chatDto =
          existing ??
          await _remoteDataSource.createChat(
            bookingId: bookingId,
            participants: participants,
            lastMessageAt: DateTime.now(),
            lastMessage: '',
            lastMessageType: 'text',
            lastMessageSenderId: '',
          );
      return Result.success(ChatMapper.toThread(chatDto));
    } catch (e) {
      return Result.failure(
        Failure(message: 'Failed to open chat', code: e.toString()),
      );
    }
  }

  static String _readString(dynamic value) {
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

  static DateTime? _readDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    return null;
  }

  Future<ChatThreadPreview?> _buildChatThreadPreview({
    required ChatDto chat,
    required String userId,
    required Map<String, Map<String, dynamic>> publicUsersData,
  }) async {
    final otherUserId = chat.participants.firstWhere(
      (id) => id != userId,
      orElse: () => '',
    );
    if (otherUserId.isEmpty) {
      return null;
    }

    final cachedUserData = publicUsersData[otherUserId];
    final userDataFuture = cachedUserData != null
        ? Future.value(cachedUserData)
        : _remoteDataSource.getPublicUserData(otherUserId);
    final fallbackLastMessageFuture = chat.lastMessage.isEmpty
        ? _remoteDataSource.getLastMessage(chat.id)
        : Future.value(null);

    final results = await Future.wait<dynamic>([
      userDataFuture,
      fallbackLastMessageFuture,
    ]);

    final userData = results[0] as Map<String, dynamic>?;
    final fallbackLastMessage = results[1] as ChatMessageDto?;

    final userName = _readString(userData?['name']);
    final userImage = _readString(userData?['photoUrl']);
    final lastSeen = _readDateTime(userData?['lastSeen']);
    final isOnline =
        lastSeen != null && DateTime.now().difference(lastSeen).inMinutes < 5;

    final lastMessage = chat.lastMessage.isNotEmpty
        ? chat.lastMessage
        : (fallbackLastMessage?.content ?? '');
    final lastMessageSenderId = chat.lastMessageSenderId.isNotEmpty
        ? chat.lastMessageSenderId
        : (fallbackLastMessage?.senderId ?? '');
    final timestamp = fallbackLastMessage?.createdAt ?? chat.lastMessageAt;

    var unreadCount = 0;
    if (lastMessage.isNotEmpty && lastMessageSenderId != userId) {
      final otherMessages = await _remoteDataSource.getMessagesFromOtherUser(
        chat.id,
        userId,
      );
      unreadCount = otherMessages
          .where((message) => !message.seenBy.contains(userId))
          .length;
    }

    return ChatThreadPreview(
      chatId: chat.id,
      userId: otherUserId,
      userName: userName,
      userImage: userImage,
      lastMessage: lastMessage,
      timestamp: timestamp,
      unreadCount: unreadCount,
      isOnline: isOnline,
    );
  }

  static String _buildPreviewContentFromMessage({
    required String type,
    required String content,
  }) {
    switch (type) {
      case 'image':
        return 'Image';
      case 'video':
        return 'Video';
      case 'document':
        return _extractDocumentName(content);
      default:
        return content.trim();
    }
  }

  static String _extractDocumentName(String content) {
    final segments = content.split('|');
    if (segments.length >= 2 && segments[1].trim().isNotEmpty) {
      return segments[1].trim();
    }
    return 'Document';
  }
}
