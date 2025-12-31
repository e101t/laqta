import 'package:luqta/core/domain/result/result.dart';
import '../entities/chat_message.dart';
import '../repositories/chat_repository.dart';

class GetChatMessages {
  final ChatRepository _repository;

  const GetChatMessages(this._repository);

  Future<Result<List<ChatMessage>>> call({required String chatId}) {
    return _repository.getMessages(chatId: chatId);
  }
}
