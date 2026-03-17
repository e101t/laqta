import 'package:laqta/core/domain/result/result.dart';
import '../entities/chat_thread.dart';
import '../repositories/chat_repository.dart';

class GetOrCreateBookingChat {
  final ChatRepository _repository;

  const GetOrCreateBookingChat(this._repository);

  Future<Result<ChatThread>> call({
    required String bookingId,
    required List<String> participants,
  }) {
    return _repository.getOrCreateChatForBooking(
      bookingId: bookingId,
      participants: participants,
    );
  }
}
