import 'package:luqta/core/domain/result/result.dart';
import '../entities/chat_message.dart';
import '../repositories/chat_repository.dart';

class SendChatMessage {
  final ChatRepository _repository;

  const SendChatMessage(this._repository);

  Future<Result<void>> call(ChatMessage message) {
    return _repository.sendMessage(message);
  }
}
