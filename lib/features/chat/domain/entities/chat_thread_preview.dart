class ChatThreadPreview {
  final String chatId;
  final String userId;
  final String userName;
  final String userImage;
  final String lastMessage;
  final DateTime timestamp;
  final int unreadCount;
  final bool isOnline;

  const ChatThreadPreview({
    required this.chatId,
    required this.userId,
    required this.userName,
    required this.userImage,
    required this.lastMessage,
    required this.timestamp,
    required this.unreadCount,
    required this.isOnline,
  });
}
