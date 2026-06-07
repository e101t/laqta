class ChatMessage {
  final String id;
  final String chatId;
  final String senderId;
  final String type; // text, image, video, document
  final String content;
  final String? mediaId;
  final String? fileName;
  final int? fileSize;
  final DateTime createdAt;
  final List<String> seenBy;

  const ChatMessage({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.type,
    required this.content,
    this.mediaId,
    this.fileName,
    this.fileSize,
    required this.createdAt,
    this.seenBy = const [],
  });

  bool isSeenBy(String userId) => seenBy.contains(userId);

  ChatMessage copyWith({
    List<String>? seenBy,
    String? content,
    String? mediaId,
    String? fileName,
    int? fileSize,
  }) {
    return ChatMessage(
      id: id,
      chatId: chatId,
      senderId: senderId,
      type: type,
      content: content ?? this.content,
      mediaId: mediaId ?? this.mediaId,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      createdAt: createdAt,
      seenBy: seenBy ?? this.seenBy,
    );
  }
}
