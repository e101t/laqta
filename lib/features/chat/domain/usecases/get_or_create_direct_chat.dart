import 'package:laqta/core/domain/result/result.dart';
import 'package:laqta/features/chat/domain/entities/chat_thread.dart';
import 'package:laqta/features/chat/domain/repositories/chat_repository.dart';

class GetOrCreateDirectChat {
  const GetOrCreateDirectChat(this._repository);

  final ChatRepository _repository;

  Future<Result<ChatThread>> call({required String participantId}) {
    return _repository.getOrCreateDirectChat(participantId: participantId);
  }
}
