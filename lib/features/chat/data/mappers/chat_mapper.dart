import 'package:laqta/features/chat/data/dtos/chat_dto.dart';
import 'package:laqta/features/chat/domain/entities/chat_message.dart';
import 'package:laqta/features/chat/domain/entities/chat_thread.dart';

class ChatMapper {
  static ChatThread toThread(ChatDto dto) {
    return ChatThread(
      id: dto.id,
      bookingId: dto.bookingId,
      participants: dto.participants,
      lastMessageAt: dto.lastMessageAt,
    );
  }

  static ChatMessage toDomain(ChatMessageDto dto) {
    return ChatMessage(
      id: dto.id,
      chatId: dto.chatId,
      senderId: dto.senderId,
      type: dto.type,
      content: dto.content,
      mediaId: dto.mediaId,
      fileName: dto.fileName,
      fileSize: dto.fileSize,
      createdAt: dto.createdAt,
      seenBy: dto.seenBy,
    );
  }

  static ChatMessageDto toDto(ChatMessage message) {
    return ChatMessageDto(
      id: message.id,
      chatId: message.chatId,
      senderId: message.senderId,
      type: message.type,
      content: message.content,
      mediaId: message.mediaId,
      fileName: message.fileName,
      fileSize: message.fileSize,
      createdAt: message.createdAt,
      seenBy: message.seenBy,
    );
  }
}
