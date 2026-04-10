import 'package:laqta/features/chat/data/dtos/chat_dto.dart';

abstract class ChatRemoteDataSource {
  String createMessageId(String chatId);

  Future<List<ChatDto>> getChatsForUser(String userId);

  Future<ChatDto> getChatById(String chatId);

  Future<ChatDto?> getChatByBookingId(String bookingId);

  Future<ChatDto> createChat({
    required String bookingId,
    required List<String> participants,
    required DateTime lastMessageAt,
    String lastMessage = '',
    String lastMessageType = 'text',
    String lastMessageSenderId = '',
  });

  Future<List<ChatMessageDto>> getMessages(String chatId);

  Future<ChatMessageDto?> getLastMessage(String chatId);

  Future<List<ChatMessageDto>> getMessagesFromOtherUser(
    String chatId,
    String currentUserId,
  );

  Future<Map<String, dynamic>?> getPublicUserData(String userId);

  Future<Map<String, Map<String, dynamic>>> getPublicUsersData(
    List<String> userIds,
  );

  Future<Map<String, dynamic>?> getUserData(String userId);

  Future<void> updateUserBlockedList(String userId, List<String> blockedUsers);

  Future<void> sendMessage(ChatMessageDto message);

  Future<void> markMessagesSeen({
    required String chatId,
    required List<ChatMessageDto> messages,
  });

  Future<void> updateChatPreview({
    required String chatId,
    required DateTime timestamp,
    required String lastMessage,
    required String lastMessageType,
    required String senderId,
  });

  Future<void> deleteChat(String chatId);

  Future<void> deleteChatWithMessages(String chatId);

  Future<String> uploadFile({
    required String storagePath,
    required String filePath,
  });
}
