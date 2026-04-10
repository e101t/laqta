import 'package:laqta/core/domain/result/result.dart';
import '../entities/chat_message.dart';
import '../entities/chat_thread.dart';
import '../entities/chat_thread_preview.dart';

abstract class ChatRepository {
  String createMessageId({required String chatId});

  Future<Result<List<ChatThreadPreview>>> getChatThreads({
    required String userId,
  });

  Future<Result<List<ChatMessage>>> getMessages({required String chatId});

  Future<Result<void>> markMessagesRead({
    required String chatId,
    required String userId,
    List<ChatMessage>? messages,
  });

  Future<Result<void>> sendMessage(ChatMessage message);

  Future<Result<ChatMessage>> sendMediaMessage({
    required String chatId,
    required String senderId,
    required String type,
    required String filePath,
    required String messageId,
    String? fileName,
    int? fileSize,
  });

  Future<Result<void>> deleteChat({required String chatId});

  Future<Result<void>> deleteChatWithMessages({required String chatId});

  Future<Result<bool>> toggleBlockUser({
    required String chatId,
    required String currentUserId,
  });

  Future<Result<String?>> getOtherParticipantId({
    required String chatId,
    required String currentUserId,
  });

  Future<Result<ChatThread>> getOrCreateChatForBooking({
    required String bookingId,
    required List<String> participants,
  });
}
