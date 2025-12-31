class ChatThread {
  final String id;
  final String bookingId;
  final List<String> participants;
  final DateTime lastMessageAt;

  const ChatThread({
    required this.id,
    required this.bookingId,
    required this.participants,
    required this.lastMessageAt,
  });
}
