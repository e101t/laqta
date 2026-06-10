import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laqta/core/domain/failures/failure.dart';
import 'package:laqta/core/domain/result/result.dart';
import 'package:laqta/features/auth/auth_dependencies.dart';
import 'package:laqta/features/auth/domain/entities/auth_user.dart';
import 'package:laqta/features/auth/domain/repositories/auth_repository.dart';
import 'package:laqta/features/chat/chat_dependencies.dart';
import 'package:laqta/features/chat/domain/entities/chat_message.dart';
import 'package:laqta/features/chat/domain/entities/chat_thread.dart';
import 'package:laqta/features/chat/domain/entities/chat_thread_preview.dart';
import 'package:laqta/features/chat/domain/repositories/chat_repository.dart';
import 'package:laqta/features/chat/presentation/screens/chat_list_screen.dart';

import '../helpers/test_app.dart';

void main() {
  setUp(() {
    AuthDependencies.setRepositoryOverride(_FakeAuthRepository());
    ChatDependencies.setRepositoryOverride(_FakeChatRepository());
  });

  tearDown(() {
    AuthDependencies.setRepositoryOverride(null);
    ChatDependencies.setRepositoryOverride(null);
  });

  testWidgets('chat list renders premium filters and backend conversations', (
    tester,
  ) async {
    await tester.pumpWidget(wrapWithMaterial(const ChatListScreen()));
    await tester.pumpAndSettle();

    expect(find.text('الرسائل'), findsOneWidget);
    expect(find.text('ابحث في الرسائل'), findsOneWidget);
    expect(find.text('الكل'), findsOneWidget);
    expect(find.text('المصورون'), findsOneWidget);
    expect(find.text('القاعات'), findsOneWidget);
    expect(find.text('الترتيبات'), findsOneWidget);
    expect(find.text('Ahmed Aliraqi'), findsOneWidget);
    expect(find.text('قاعة رويال لايف'), findsOneWidget);

    await tester.tap(find.text('القاعات'));
    await tester.pumpAndSettle();

    expect(find.text('قاعة رويال لايف'), findsOneWidget);
    expect(find.text('Ahmed Aliraqi'), findsNothing);
  });

  testWidgets('chat list search narrows the visible conversations', (
    tester,
  ) async {
    await tester.pumpWidget(wrapWithMaterial(const ChatListScreen()));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Sara');
    await tester.pumpAndSettle();

    expect(find.text('Sara Photography'), findsOneWidget);
    expect(find.text('Ahmed Aliraqi'), findsNothing);
  });
}

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<Result<AuthUser?>> getCurrentUser() async {
    return Result.success(AuthUser(id: 'user_1', isAnonymous: false));
  }

  @override
  Future<Result<void>> deleteCurrentUser() async => Result.success(null);

  @override
  Future<Result<void>> signOut() async => Result.success(null);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeChatRepository implements ChatRepository {
  @override
  String createMessageId({required String chatId}) => 'msg_test';

  @override
  Future<Result<List<ChatThreadPreview>>> getChatThreads({
    required String userId,
  }) async {
    return Result.success([
      ChatThreadPreview(
        chatId: 'room_1',
        userId: 'photographer_1',
        userName: 'Ahmed Aliraqi',
        userImage: '',
        lastMessage: 'متى تكون متاح للحجز؟',
        timestamp: DateTime(2026, 5, 24, 10, 30),
        unreadCount: 2,
        isOnline: false,
      ),
      ChatThreadPreview(
        chatId: 'room_2',
        userId: 'venue_1',
        userName: 'قاعة رويال لايف',
        userImage: '',
        lastMessage: 'شكرا لتواصلك معنا',
        timestamp: DateTime(2026, 5, 24, 9, 45),
        unreadCount: 1,
        isOnline: false,
      ),
      ChatThreadPreview(
        chatId: 'room_3',
        userId: 'photographer_2',
        userName: 'Sara Photography',
        userImage: '',
        lastMessage: 'تم تأكيد الحجز',
        timestamp: DateTime(2026, 5, 23),
        unreadCount: 0,
        isOnline: false,
      ),
    ]);
  }

  @override
  Future<Result<void>> deleteChat({required String chatId}) async {
    return Result.success(null);
  }

  @override
  Future<Result<void>> deleteChatWithMessages({required String chatId}) async {
    return Result.success(null);
  }

  @override
  Future<Result<List<ChatMessage>>> getMessages({
    required String chatId,
  }) async {
    return Result.success([]);
  }

  @override
  Future<Result<ChatThread>> getOrCreateChatForBooking({
    required String bookingId,
    required List<String> participants,
  }) async {
    return Result.failure(const Failure(message: 'not implemented'));
  }

  @override
  Future<Result<ChatThread>> getOrCreateDirectChat({
    required String participantId,
  }) async {
    return Result.failure(const Failure(message: 'not implemented'));
  }

  @override
  Future<Result<String?>> getOtherParticipantId({
    required String chatId,
    required String currentUserId,
  }) async {
    return Result.success('other_user');
  }

  @override
  Future<Result<void>> markMessagesRead({
    required String chatId,
    required String userId,
    List<ChatMessage>? messages,
  }) async {
    return Result.success(null);
  }

  @override
  Future<Result<ChatMessage>> sendMediaMessage({
    required String chatId,
    required String senderId,
    required String type,
    required String filePath,
    required String messageId,
    String? fileName,
    int? fileSize,
  }) async {
    return Result.failure(const Failure(message: 'not implemented'));
  }

  @override
  Future<Result<void>> sendMessage(ChatMessage message) async {
    return Result.success(null);
  }

  @override
  Future<Result<bool>> toggleBlockUser({
    required String chatId,
    required String currentUserId,
  }) async {
    return Result.success(false);
  }
}
