import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luqta/core/domain/failures/failure.dart';
import 'package:luqta/core/domain/result/result.dart';
import 'package:luqta/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:luqta/features/chat/data/mappers/chat_mapper.dart';
import 'package:luqta/features/chat/domain/entities/chat_message.dart';
import 'package:luqta/features/chat/domain/entities/chat_thread.dart';
import 'package:luqta/features/chat/domain/entities/chat_thread_preview.dart';
import 'package:luqta/features/chat/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource _remoteDataSource;

  const ChatRepositoryImpl(this._remoteDataSource);

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
      final previews = <ChatThreadPreview>[];

      for (final chat in chats) {
        final otherUserId = chat.participants.firstWhere(
          (id) => id != userId,
          orElse: () => '',
        );
        if (otherUserId.isEmpty) {
          continue;
        }

        final userData = await _remoteDataSource.getPublicUserData(otherUserId);
        final userName = _readString(userData?['name']);
        final userImage = _readString(userData?['photoUrl']);
        final lastSeen = _readDateTime(userData?['lastSeen']);
        final isOnline =
            lastSeen != null &&
            DateTime.now().difference(lastSeen).inMinutes < 5;

        final lastMessageDto = await _remoteDataSource.getLastMessage(chat.id);
        final lastMessage = lastMessageDto?.content ?? '';
        final timestamp = lastMessageDto?.createdAt ?? chat.lastMessageAt;

        int unreadCount = 0;
        if (lastMessageDto != null) {
          final otherMessages = await _remoteDataSource
              .getMessagesFromOtherUser(chat.id, userId);
          unreadCount = otherMessages
              .where((message) => !message.seenBy.contains(userId))
              .length;
        }

        previews.add(
          ChatThreadPreview(
            chatId: chat.id,
            userId: otherUserId,
            userName: userName,
            userImage: userImage,
            lastMessage: lastMessage,
            timestamp: timestamp,
            unreadCount: unreadCount,
            isOnline: isOnline,
          ),
        );
      }

      return Result.success(previews);
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
  Future<Result<void>> sendMessage(ChatMessage message) async {
    try {
      final dto = ChatMapper.toDto(message);
      await _remoteDataSource.sendMessage(dto);
      await _remoteDataSource.updateLastMessageAt(
        message.chatId,
        DateTime.now(),
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
      final storagePath = _resolveStoragePath(
        type: type,
        chatId: chatId,
        messageId: messageId,
        fileName: fileName,
      );
      final downloadUrl = await _remoteDataSource.uploadFile(
        storagePath: storagePath,
        filePath: filePath,
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
      await _remoteDataSource.updateLastMessageAt(chatId, DateTime.now());

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

  static String _resolveStoragePath({
    required String type,
    required String chatId,
    required String messageId,
    String? fileName,
  }) {
    switch (type) {
      case 'image':
        return 'chat_images/$chatId/$messageId.jpg';
      case 'video':
        return 'chat_videos/$chatId/$messageId.mp4';
      case 'document':
        final safeName = fileName?.isNotEmpty == true ? fileName! : 'document';
        return 'chat_documents/$chatId/${messageId}_$safeName';
      default:
        return 'chat_files/$chatId/$messageId';
    }
  }
}
