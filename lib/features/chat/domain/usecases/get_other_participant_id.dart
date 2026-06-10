import 'package:laqta/core/domain/result/result.dart';
import '../repositories/chat_repository.dart';

class GetOtherParticipantId {
  final ChatRepository _repository;

  const GetOtherParticipantId(this._repository);

  Future<Result<String?>> call({
    required String chatId,
    required String currentUserId,
  }) {
    return _repository.getOtherParticipantId(
      chatId: chatId,
      currentUserId: currentUserId,
    );
  }
}
