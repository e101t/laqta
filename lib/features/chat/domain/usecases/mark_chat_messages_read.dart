import 'package:laqta/core/domain/result/result.dart';
import '../entities/chat_message.dart';
import '../repositories/chat_repository.dart';

class MarkChatMessagesRead {
  final ChatRepository _repository;

  const MarkChatMessagesRead(this._repository);

  Future<Result<void>> call({
    required String chatId,
    required String userId,
    List<ChatMessage>? messages,
  }) {
    return _repository.markMessagesRead(
      chatId: chatId,
      userId: userId,
      messages: messages,
    );
  }
}
