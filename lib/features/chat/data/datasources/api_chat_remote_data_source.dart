import 'package:laqta/core/constants/app_constants.dart';
import 'package:laqta/core/services/backend_api_client.dart';
import 'package:laqta/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:laqta/features/chat/data/dtos/chat_dto.dart';

class ApiChatRemoteDataSource implements ChatRemoteDataSource {
  ApiChatRemoteDataSource({BackendApiClient? apiClient})
    : _apiClient = apiClient ?? BackendApiClient();

  final BackendApiClient _apiClient;

  @override
  String createMessageId(String chatId) {
    return 'msg_${DateTime.now().microsecondsSinceEpoch}';
  }

  @override
  Future<List<ChatDto>> getChatsForUser(String userId) async {
    final response = await _apiClient.get(
      '/chat/rooms?limit=${AppConstants.queryLimit}',
    );
    return _readRooms(response);
  }

  @override
  Future<ChatDto> getChatById(String chatId) async {
    final response = await _apiClient.get(
      '/chat/rooms/${Uri.encodeComponent(chatId)}',
    );
    final payload = response as Map<String, dynamic>;
    final room = payload['room'];
    if (room is! Map<String, dynamic>) {
      throw const BackendApiException('Chat room payload is invalid.');
    }
    return ChatDto.fromJson(room);
  }

  @override
  Future<ChatDto?> getChatByBookingId(String bookingId) async {
    final response = await _apiClient.get(
      '/chat/rooms?bookingId=${Uri.encodeQueryComponent(bookingId)}',
    );
    final rooms = _readRooms(response);
    return rooms.isEmpty ? null : rooms.first;
  }

  @override
  Future<ChatDto> createChat({
    required String bookingId,
    required List<String> participants,
    required DateTime lastMessageAt,
    String lastMessage = '',
    String lastMessageType = 'text',
    String lastMessageSenderId = '',
  }) async {
    final response = await _apiClient.post(
      '/chat/rooms',
      body: {'bookingId': bookingId},
    );
    final payload = response as Map<String, dynamic>;
    final room = payload['room'];
    if (room is! Map<String, dynamic>) {
      throw const BackendApiException('Chat room payload is invalid.');
    }
    return ChatDto.fromJson(room);
  }

  @override
  Future<ChatDto> createDirectChat({required String participantId}) async {
    final response = await _apiClient.post(
      '/chat/rooms',
      body: {'participantId': participantId},
    );
    final payload = response as Map<String, dynamic>;
    final room = payload['room'];
    if (room is! Map<String, dynamic>) {
      throw const BackendApiException('Chat room payload is invalid.');
    }
    return ChatDto.fromJson(room);
  }

  @override
  Future<List<ChatMessageDto>> getMessages(String chatId) async {
    final response = await _apiClient.get(
      '/chat/messages?roomId=${Uri.encodeQueryComponent(chatId)}&limit=${AppConstants.chatMessagesLimit}',
    );
    return _readMessages(response);
  }

  @override
  Future<ChatMessageDto?> getLastMessage(String chatId) async {
    final response = await _apiClient.get(
      '/chat/messages/last?roomId=${Uri.encodeQueryComponent(chatId)}',
    );
    final payload = response as Map<String, dynamic>;
    final message = payload['message'];
    if (message == null) {
      return null;
    }
    if (message is! Map<String, dynamic>) {
      throw const BackendApiException('Chat message payload is invalid.');
    }
    return ChatMessageDto.fromJson(message);
  }

  @override
  Future<List<ChatMessageDto>> getMessagesFromOtherUser(
    String chatId,
    String currentUserId,
  ) async {
    final response = await _apiClient.get(
      '/chat/messages?roomId=${Uri.encodeQueryComponent(chatId)}&otherThanSenderId=${Uri.encodeQueryComponent(currentUserId)}&limit=${AppConstants.chatMessagesLimit}',
    );
    return _readMessages(response);
  }

  @override
  Future<Map<String, dynamic>?> getPublicUserData(String userId) async {
    final users = await getPublicUsersData([userId]);
    return users[userId];
  }

  @override
  Future<Map<String, Map<String, dynamic>>> getPublicUsersData(
    List<String> userIds,
  ) async {
    if (userIds.isEmpty) {
      return <String, Map<String, dynamic>>{};
    }

    final response = await _apiClient.get(
      '/users/public?ids=${Uri.encodeQueryComponent(userIds.join(','))}',
    );
    final payload = response as Map<String, dynamic>;
    final users = payload['users'];
    if (users is! List) {
      return <String, Map<String, dynamic>>{};
    }

    final mapped = <String, Map<String, dynamic>>{};
    for (final entry in users) {
      if (entry is! Map<String, dynamic>) {
        continue;
      }
      final id = entry['id'];
      if (id is String && id.isNotEmpty) {
        mapped[id] = entry;
      }
    }
    return mapped;
  }

  @override
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    final response = await _apiClient.get('/users/me');
    final payload = response as Map<String, dynamic>;
    final user = payload['user'];
    if (user is! Map<String, dynamic>) {
      return null;
    }
    return user;
  }

  @override
  Future<void> updateUserBlockedList(
    String userId,
    List<String> blockedUsers,
  ) async {
    await _apiClient.patch('/users/me', body: {'blockedUsers': blockedUsers});
  }

  @override
  Future<void> sendMessage(ChatMessageDto message) async {
    await _apiClient.post(
      '/chat/messages',
      body: {
        'id': message.id,
        'roomId': message.chatId,
        'type': message.type,
        'content': message.content,
        'mediaId': message.mediaId,
        'fileName': message.fileName,
        'fileSize': message.fileSize,
        'createdAt': message.createdAt.toUtc().toIso8601String(),
      },
    );
  }

  @override
  Future<void> markMessagesSeen({
    required String chatId,
    required List<ChatMessageDto> messages,
  }) async {
    if (messages.isEmpty) {
      return;
    }

    final latest = messages
        .map((message) => message.createdAt)
        .reduce((current, next) => current.isAfter(next) ? current : next);

    await _apiClient.post(
      '/chat/reads',
      body: {'roomId': chatId, 'lastReadAt': latest.toUtc().toIso8601String()},
    );
  }

  @override
  Future<void> updateChatPreview({
    required String chatId,
    required DateTime timestamp,
    required String lastMessage,
    required String lastMessageType,
    required String senderId,
  }) async {
    await _apiClient.patch(
      '/chat/rooms/${Uri.encodeComponent(chatId)}/preview',
      body: {
        'timestamp': timestamp.toUtc().toIso8601String(),
        'lastMessage': lastMessage,
        'lastMessageType': lastMessageType,
        'senderId': senderId,
      },
    );
  }

  @override
  Future<void> deleteChat(String chatId) async {
    await _apiClient.delete('/chat/rooms/${Uri.encodeComponent(chatId)}');
  }

  @override
  Future<void> deleteChatWithMessages(String chatId) async {
    await _apiClient.delete('/chat/rooms/${Uri.encodeComponent(chatId)}');
  }

  List<ChatDto> _readRooms(dynamic response) {
    final payload = response as Map<String, dynamic>;
    final rooms = payload['rooms'];
    if (rooms is! List) {
      return <ChatDto>[];
    }
    return rooms
        .whereType<Map<String, dynamic>>()
        .map(ChatDto.fromJson)
        .toList();
  }

  List<ChatMessageDto> _readMessages(dynamic response) {
    final payload = response as Map<String, dynamic>;
    final messages = payload['messages'];
    if (messages is! List) {
      return <ChatMessageDto>[];
    }
    return messages
        .whereType<Map<String, dynamic>>()
        .map(ChatMessageDto.fromJson)
        .toList();
  }
}
