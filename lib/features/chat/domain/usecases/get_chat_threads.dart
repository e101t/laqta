import 'package:luqta/core/domain/result/result.dart';
import '../entities/chat_thread_preview.dart';
import '../repositories/chat_repository.dart';

class GetChatThreads {
  final ChatRepository _repository;

  const GetChatThreads(this._repository);

  Future<Result<List<ChatThreadPreview>>> call({required String userId}) {
    return _repository.getChatThreads(userId: userId);
  }
}
