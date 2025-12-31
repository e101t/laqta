import 'package:luqta/core/domain/result/result.dart';
import '../repositories/chat_repository.dart';

class ToggleBlockUser {
  final ChatRepository _repository;

  const ToggleBlockUser(this._repository);

  Future<Result<bool>> call({
    required String chatId,
    required String currentUserId,
  }) {
    return _repository.toggleBlockUser(
      chatId: chatId,
      currentUserId: currentUserId,
    );
  }
}
