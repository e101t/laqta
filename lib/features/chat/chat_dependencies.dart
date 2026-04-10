import 'package:flutter/foundation.dart';
import 'package:laqta/core/services/backend_config.dart';
import 'package:laqta/features/chat/data/datasources/api_chat_remote_data_source.dart';
import 'package:laqta/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:laqta/features/chat/data/datasources/firestore_chat_remote_data_source.dart';
import 'package:laqta/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:laqta/features/chat/domain/repositories/chat_repository.dart';
import 'package:laqta/features/chat/domain/usecases/delete_chat.dart';
import 'package:laqta/features/chat/domain/usecases/delete_chat_with_messages.dart';
import 'package:laqta/features/chat/domain/usecases/generate_message_id.dart';
import 'package:laqta/features/chat/domain/usecases/get_or_create_booking_chat.dart';
import 'package:laqta/features/chat/domain/usecases/get_chat_messages.dart';
import 'package:laqta/features/chat/domain/usecases/get_chat_threads.dart';
import 'package:laqta/features/chat/domain/usecases/get_other_participant_id.dart';
import 'package:laqta/features/chat/domain/usecases/mark_chat_messages_read.dart';
import 'package:laqta/features/chat/domain/usecases/send_chat_media_message.dart';
import 'package:laqta/features/chat/domain/usecases/send_chat_message.dart';
import 'package:laqta/features/chat/domain/usecases/toggle_block_user.dart';

class ChatDependencies {
  static ChatRemoteDataSource? _remoteDataSource;
  static ChatRepository? _repositoryOverride;

  @visibleForTesting
  static void setRepositoryOverride(ChatRepository? repository) {
    _repositoryOverride = repository;
  }

  static ChatRepository get _repository =>
      _repositoryOverride ?? ChatRepositoryImpl(_remote);

  static ChatRemoteDataSource get _remote =>
      _remoteDataSource ??= (BackendConfig.useBackendChat
      ? ApiChatRemoteDataSource()
      : FirestoreChatRemoteDataSource());

  static GetChatThreads getChatThreads() => GetChatThreads(_repository);

  static GetChatMessages getChatMessages() => GetChatMessages(_repository);

  static MarkChatMessagesRead markChatMessagesRead() =>
      MarkChatMessagesRead(_repository);

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
