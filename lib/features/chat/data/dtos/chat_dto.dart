import 'package:laqta/core/utils/legacy_data_compat.dart';

class ChatDto {
  final String id;
  final String bookingId;
  final List<String> participants;
  final DateTime lastMessageAt;
  final String lastMessage;
  final String lastMessageType;
  final String lastMessageSenderId;
  final int unreadCount;
  final String otherUserName;
  final String otherUserImage;
  final DateTime? otherUserLastSeen;

  const ChatDto({
    required this.id,
    required this.bookingId,
    required this.participants,
    required this.lastMessageAt,
    this.lastMessage = '',
    this.lastMessageType = 'text',
    this.lastMessageSenderId = '',
    this.unreadCount = 0,
    this.otherUserName = '',
    this.otherUserImage = '',
    this.otherUserLastSeen,
  });

  factory ChatDto.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return ChatDto(
      id: doc.id,
      bookingId: _readString(data, 'bookingId'),
      participants: _readStringList(data['participants']),
      lastMessageAt: _readDateTime(data['lastMessageAt']),
      lastMessage: _readString(data, 'lastMessage'),
      lastMessageType: _readString(data, 'lastMessageType', fallback: 'text'),
      lastMessageSenderId: _readString(data, 'lastMessageSenderId'),
    );
  }

  factory ChatDto.fromJson(Map<String, dynamic> json) {
    final otherUser = json['otherUser'];
    return ChatDto(
      id: json['id'] as String,
      bookingId: json['bookingId'] as String,
      participants: (json['participants'] as List<dynamic>).cast<String>(),
      lastMessageAt: DateTime.parse(json['lastMessageAt']),
      lastMessage: json['lastMessage'] as String? ?? '',
      lastMessageType: json['lastMessageType'] as String? ?? 'text',
      lastMessageSenderId: json['lastMessageSenderId'] as String? ?? '',
      unreadCount: _readInt(json['unreadCount']),
      otherUserName: otherUser is Map<String, dynamic>
          ? _readString(otherUser, 'name')
          : '',
      otherUserImage: otherUser is Map<String, dynamic>
          ? _readString(otherUser, 'photoUrl')
          : '',
      otherUserLastSeen: otherUser is Map<String, dynamic>
          ? _readDateTimeOrNull(otherUser['lastSeen'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bookingId': bookingId,
      'participants': participants,
      'lastMessageAt': Timestamp.fromDate(lastMessageAt),
      'lastMessage': lastMessage,
      'lastMessageType': lastMessageType,
      'lastMessageSenderId': lastMessageSenderId,
      'unreadCount': unreadCount,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookingId': bookingId,
      'participants': participants,
      'lastMessageAt': lastMessageAt.toIso8601String(),
      'lastMessage': lastMessage,
      'lastMessageType': lastMessageType,
      'lastMessageSenderId': lastMessageSenderId,
      'unreadCount': unreadCount,
    };
  }

  static String _readString(
    Map<String, dynamic> data,
    String key, {
    String fallback = '',
  }) {
    final value = data[key];
    if (value is String) {
      return value;
    }
    return fallback;
  }

  static List<String> _readStringList(dynamic value) {
    if (value is List) {
      return value.whereType<String>().toList();
    }
    return <String>[];
  }

  static DateTime _readDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    return DateTime.now();
  }

  static DateTime? _readDateTimeOrNull(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value)?.toLocal();
    }
    return null;
  }

  static int _readInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return 0;
  }
}

class ChatMessageDto {
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

  const ChatMessageDto({
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

  factory ChatMessageDto.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return ChatMessageDto(
      id: doc.id,
      chatId: _readString(data, 'chatId'),
      senderId: _readString(data, 'senderId'),
      type: _readString(data, 'type', fallback: 'text'),
      content: _readString(data, 'content'),
      mediaId: _readNullableString(data, 'mediaId'),
      fileName: _readNullableString(data, 'fileName'),
      fileSize: _readNullableInt(data, 'fileSize'),
      createdAt: ChatDto._readDateTime(data['createdAt']),
      seenBy: ChatDto._readStringList(data['seenBy']),
    );
  }

  factory ChatMessageDto.fromJson(Map<String, dynamic> json) {
    return ChatMessageDto(
      id: json['id'] as String,
      chatId: json['chatId'] as String,
      senderId: json['senderId'] as String,
      type: json['type'] as String,
      content: json['content'] as String,
      mediaId: json['mediaId'] as String?,
      fileName: json['fileName'] as String?,
      fileSize: json['fileSize'] as int?,
      createdAt: DateTime.parse(json['createdAt']),
      seenBy: (json['seenBy'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'chatId': chatId,
      'senderId': senderId,
      'type': type,
      'content': content,
      'mediaId': mediaId,
      'fileName': fileName,
      'fileSize': fileSize,
      'createdAt': Timestamp.fromDate(createdAt),
      'seenBy': seenBy,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chatId': chatId,
      'senderId': senderId,
      'type': type,
      'content': content,
      'mediaId': mediaId,
      'fileName': fileName,
      'fileSize': fileSize,
      'createdAt': createdAt.toIso8601String(),
      'seenBy': seenBy,
    };
  }

  static String _readString(
    Map<String, dynamic> data,
    String key, {
    String fallback = '',
  }) {
    final value = data[key];
    if (value is String) {
      return value;
    }
    return fallback;
  }

  static String? _readNullableString(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is String && value.trim().isNotEmpty) {
      return value;
    }
    return null;
  }

  static int? _readNullableInt(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return null;
  }
}
