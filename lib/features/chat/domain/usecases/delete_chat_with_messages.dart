import 'package:luqta/core/domain/result/result.dart';
import '../repositories/chat_repository.dart';

class DeleteChatWithMessages {
  final ChatRepository _repository;

  const DeleteChatWithMessages(this._repository);

  Future<Result<void>> call({required String chatId}) {
    return _repository.deleteChatWithMessages(chatId: chatId);
  }
}
