import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:luqta/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:luqta/features/chat/data/dtos/chat_dto.dart';

class FirestoreChatRemoteDataSource implements ChatRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  FirestoreChatRemoteDataSource({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _storage = storage ?? FirebaseStorage.instance;

  CollectionReference<Map<String, dynamic>> get _chatsCollection =>
      _firestore.collection('chats');

  @override
  String createMessageId(String chatId) {
    return _chatsCollection.doc(chatId).collection('messages').doc().id;
  }

  @override
  Future<List<ChatDto>> getChatsForUser(String userId) async {
    final snapshot = await _chatsCollection
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageAt', descending: true)
        .get();

    return snapshot.docs.map(ChatDto.fromFirestore).toList();
  }

  @override
  Future<ChatDto> getChatById(String chatId) async {
    final doc = await _chatsCollection.doc(chatId).get();
    if (!doc.exists) {
      throw StateError('Chat not found');
    }
    return ChatDto.fromFirestore(doc);
  }

  @override
  Future<ChatDto?> getChatByBookingId(String bookingId) async {
    final snapshot = await _chatsCollection
        .where('bookingId', isEqualTo: bookingId)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) {
      return null;
    }
    return ChatDto.fromFirestore(snapshot.docs.first);
  }

  @override
  Future<ChatDto> createChat({
    required String bookingId,
    required List<String> participants,
    required DateTime lastMessageAt,
  }) async {
    final docRef = _chatsCollection.doc();
    final chat = ChatDto(
      id: docRef.id,
      bookingId: bookingId,
      participants: participants,
      lastMessageAt: lastMessageAt,
    );
    await docRef.set(chat.toMap());
    return chat;
  }

  @override
  Future<List<ChatMessageDto>> getMessages(String chatId) async {
    final snapshot = await _chatsCollection
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .get();

    return snapshot.docs.map(ChatMessageDto.fromFirestore).toList();
  }

  @override
  Future<ChatMessageDto?> getLastMessage(String chatId) async {
    final snapshot = await _chatsCollection
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return null;
    }
    return ChatMessageDto.fromFirestore(snapshot.docs.first);
  }

  @override
  Future<List<ChatMessageDto>> getMessagesFromOtherUser(
    String chatId,
    String currentUserId,
  ) async {
    final snapshot = await _chatsCollection
        .doc(chatId)
        .collection('messages')
        .where('senderId', isNotEqualTo: currentUserId)
        .get();

    return snapshot.docs.map(ChatMessageDto.fromFirestore).toList();
  }

  @override
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    return doc.data();
  }

  @override
  Future<void> updateUserBlockedList(
    String userId,
    List<String> blockedUsers,
  ) async {
    await _firestore.collection('users').doc(userId).update({
      'blockedUsers': blockedUsers,
    });
  }

  @override
  Future<void> sendMessage(ChatMessageDto message) async {
    await _chatsCollection
        .doc(message.chatId)
        .collection('messages')
        .doc(message.id)
        .set(message.toMap());
  }

  @override
  Future<void> updateLastMessageAt(String chatId, DateTime timestamp) async {
    await _chatsCollection.doc(chatId).update({
      'lastMessageAt': Timestamp.fromDate(timestamp),
    });
  }

  @override
  Future<void> deleteChat(String chatId) async {
    await _chatsCollection.doc(chatId).delete();
  }

  @override
  Future<void> deleteChatWithMessages(String chatId) async {
    final messagesSnapshot = await _chatsCollection
        .doc(chatId)
        .collection('messages')
        .get();

    final batch = _firestore.batch();
    for (final doc in messagesSnapshot.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(_chatsCollection.doc(chatId));

    await batch.commit();
  }

  @override
  Future<String> uploadFile({
    required String storagePath,
    required String filePath,
  }) async {
    final storageRef = _storage.ref().child(storagePath);
    final file = File(filePath);
    await storageRef.putFile(file);
    return storageRef.getDownloadURL();
  }
}
