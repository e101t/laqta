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
import 'package:laqta/features/chat/presentation/screens/chat_screen.dart';

import '../helpers/test_app.dart';

void main() {
  setUp(() {
    _FakeChatRepository.sendMessageCalls = 0;
    AuthDependencies.setRepositoryOverride(_FakeAuthRepository());
    ChatDependencies.setRepositoryOverride(_FakeChatRepository());
  });

  tearDown(() {
    AuthDependencies.setRepositoryOverride(null);
    ChatDependencies.setRepositoryOverride(null);
  });

  testWidgets('chat quick message fills the input without sending', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapWithMaterial(
        const ChatScreen(chatId: 'room_1', otherUserName: 'Ahmed Aliraqi'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('كم سعر جلسة تصوير؟'), findsOneWidget);

    await tester.tap(find.text('كم سعر جلسة تصوير؟'));
    await tester.pumpAndSettle();

    expect(
      find.widgetWithText(TextFormField, 'كم سعر جلسة تصوير؟'),
      findsOneWidget,
    );
    expect(_FakeChatRepository.sendMessageCalls, 0);
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
  static int sendMessageCalls = 0;

  @override
  String createMessageId({required String chatId}) => 'msg_test';

  @override
  Future<Result<List<ChatThreadPreview>>> getChatThreads({
    required String userId,
  }) async {
    return Result.success(const []);
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
    return Result.success(const []);
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
    sendMessageCalls++;
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
