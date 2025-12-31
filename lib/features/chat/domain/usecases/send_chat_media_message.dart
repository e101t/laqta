import 'package:luqta/core/domain/result/result.dart';
import '../entities/chat_message.dart';
import '../repositories/chat_repository.dart';

class SendChatMediaMessage {
  final ChatRepository _repository;

  const SendChatMediaMessage(this._repository);

  Future<Result<ChatMessage>> call({
    required String chatId,
    required String senderId,
    required String type,
    required String filePath,
    required String messageId,
    String? fileName,
    int? fileSize,
  }) {
    return _repository.sendMediaMessage(
      chatId: chatId,
      senderId: senderId,
      type: type,
      filePath: filePath,
      messageId: messageId,
      fileName: fileName,
      fileSize: fileSize,
    );
  }
}
