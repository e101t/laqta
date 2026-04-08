import 'package:laqta/core/services/backend_api_client.dart';
import 'package:laqta/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:laqta/features/chat/data/dtos/chat_dto.dart';

class ApiChatRemoteDataSource implements ChatRemoteDataSource {
  const ApiChatRemoteDataSource();

  BackendApiException _unsupported() => const BackendApiException(
    'Chat APIs are not supported by the backend yet.',
  );

  @override
  String createMessageId(String chatId) {
    return 'msg_${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Future<List<ChatDto>> getChatsForUser(String userId) async {
    throw _unsupported();
  }

  @override
  Future<ChatDto> getChatById(String chatId) async {
    throw _unsupported();
  }

  @override
  Future<ChatDto?> getChatByBookingId(String bookingId) async {
    throw _unsupported();
  }

  @override
  Future<ChatDto> createChat({
    required String bookingId,
    required List<String> participants,
    required DateTime lastMessageAt,
    String lastMessage = '',
    String lastMessageType = 'text',
    String lastMessageSenderId = '',
  }) async {
    throw _unsupported();
  }

  @override
  Future<List<ChatMessageDto>> getMessages(String chatId) async {
    throw _unsupported();
  }

  @override
  Future<ChatMessageDto?> getLastMessage(String chatId) async {
    throw _unsupported();
  }

  @override
  Future<List<ChatMessageDto>> getMessagesFromOtherUser(
    String chatId,
    String currentUserId,
  ) async {
    throw _unsupported();
  }

  @override
  Future<Map<String, dynamic>?> getPublicUserData(String userId) async {
    throw _unsupported();
  }

  @override
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    throw _unsupported();
  }

  @override
  Future<void> updateUserBlockedList(
    String userId,
    List<String> blockedUsers,
  ) async {
    throw _unsupported();
  }

  @override
  Future<void> sendMessage(ChatMessageDto message) async {
    throw _unsupported();
  }

  @override
  Future<void> updateChatPreview({
    required String chatId,
    required DateTime timestamp,
    required String lastMessage,
    required String lastMessageType,
    required String senderId,
  }) async {
    throw _unsupported();
  }

  @override
  Future<void> deleteChat(String chatId) async {
    throw _unsupported();
  }

  @override
  Future<void> deleteChatWithMessages(String chatId) async {
    throw _unsupported();
  }

  @override
  Future<String> uploadFile({
    required String storagePath,
    required String filePath,
  }) async {
    throw _unsupported();
  }
}
