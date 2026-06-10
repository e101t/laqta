import 'package:laqta/core/domain/result/result.dart';
import '../repositories/chat_repository.dart';

class DeleteChat {
  final ChatRepository _repository;

  const DeleteChat(this._repository);

  Future<Result<void>> call({required String chatId}) {
    return _repository.deleteChat(chatId: chatId);
  }
}
