class ChatMessage {
  final String id;
  final String chatId;
  final String senderId;
  final String type; // text, image, video, document
  final String content;
  final DateTime createdAt;
  final List<String> seenBy;

  const ChatMessage({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.type,
    required this.content,
    required this.createdAt,
    this.seenBy = const [],
  });

  bool isSeenBy(String userId) => seenBy.contains(userId);

  ChatMessage copyWith({List<String>? seenBy}) {
    return ChatMessage(
      id: id,
      chatId: chatId,
      senderId: senderId,
      type: type,
      content: content,
      createdAt: createdAt,
      seenBy: seenBy ?? this.seenBy,
    );
  }
}
