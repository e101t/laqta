import 'package:flutter/foundation.dart';
import 'package:luqta/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:luqta/features/chat/data/datasources/firestore_chat_remote_data_source.dart';
import 'package:luqta/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:luqta/features/chat/domain/repositories/chat_repository.dart';
import 'package:luqta/features/chat/domain/usecases/delete_chat.dart';
import 'package:luqta/features/chat/domain/usecases/delete_chat_with_messages.dart';
import 'package:luqta/features/chat/domain/usecases/generate_message_id.dart';
import 'package:luqta/features/chat/domain/usecases/get_or_create_booking_chat.dart';
import 'package:luqta/features/chat/domain/usecases/get_chat_messages.dart';
import 'package:luqta/features/chat/domain/usecases/get_chat_threads.dart';
import 'package:luqta/features/chat/domain/usecases/get_other_participant_id.dart';
import 'package:luqta/features/chat/domain/usecases/send_chat_media_message.dart';
import 'package:luqta/features/chat/domain/usecases/send_chat_message.dart';
import 'package:luqta/features/chat/domain/usecases/toggle_block_user.dart';

class ChatDependencies {
  static final ChatRemoteDataSource _remoteDataSource =
      FirestoreChatRemoteDataSource();
  static ChatRepository? _repositoryOverride;

  @visibleForTesting
  static void setRepositoryOverride(ChatRepository? repository) {
    _repositoryOverride = repository;
  }

  static ChatRepository get _repository =>
      _repositoryOverride ?? ChatRepositoryImpl(_remoteDataSource);

  static GetChatThreads getChatThreads() => GetChatThreads(_repository);

  static GetChatMessages getChatMessages() => GetChatMessages(_repository);

  static GenerateMessageId generateMessageId() =>
      GenerateMessageId(_repository);

  static SendChatMessage sendChatMessage() => SendChatMessage(_repository);

  static SendChatMediaMessage sendChatMediaMessage() =>
      SendChatMediaMessage(_repository);

  static DeleteChat deleteChat() => DeleteChat(_repository);

  static DeleteChatWithMessages deleteChatWithMessages() =>
      DeleteChatWithMessages(_repository);

  static ToggleBlockUser toggleBlockUser() => ToggleBlockUser(_repository);

  static GetOtherParticipantId getOtherParticipantId() =>
      GetOtherParticipantId(_repository);

  static GetOrCreateBookingChat getOrCreateBookingChat() =>
      GetOrCreateBookingChat(_repository);
}
