import '../repositories/chat_repository.dart';

class GenerateMessageId {
  final ChatRepository _repository;

  const GenerateMessageId(this._repository);

  String call({required String chatId}) {
    return _repository.createMessageId(chatId: chatId);
  }
}
