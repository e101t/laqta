import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laqta/core/domain/result/result.dart';
import 'package:laqta/core/localization/app_localizations.dart';
import 'package:laqta/features/auth/auth_dependencies.dart';
import 'package:laqta/features/auth/domain/entities/auth_user.dart';
import 'package:laqta/features/auth/domain/repositories/auth_repository.dart';
import 'package:laqta/features/chat/chat_dependencies.dart';
import 'package:laqta/features/chat/domain/entities/chat_thread_preview.dart';
import 'package:laqta/features/chat/domain/repositories/chat_repository.dart';
import 'package:laqta/features/chat/presentation/screens/chat_list_screen.dart';

void main() {
  tearDown(() {
    AuthDependencies.setRepositoryOverride(null);
    ChatDependencies.setRepositoryOverride(null);
  });

  testWidgets('chat list empty state is localized in Arabic', (tester) async {
    AuthDependencies.setRepositoryOverride(_FakeAuthRepository());
    ChatDependencies.setRepositoryOverride(_EmptyChatRepository());

    await tester.pumpWidget(
      MaterialApp(
        home: const ChatListScreen(),
        locale: const Locale('ar'),
        supportedLocales: const [Locale('en'), Locale('ar')],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
      ),
    );
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(ChatListScreen));
    final localizations = AppLocalizations.of(context);

    expect(find.text(localizations.noMessagesTitle), findsOneWidget);
    expect(
      find.text(localizations.startConversationWithPhotographer),
      findsOneWidget,
    );
  });
}

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<Result<AuthUser?>> getCurrentUser() async =>
      Result.success(const AuthUser(id: 'user-1', isAnonymous: false));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _EmptyChatRepository implements ChatRepository {
  @override
  String createMessageId({required String chatId}) => 'message-1';

  @override
  Future<Result<List<ChatThreadPreview>>> getChatThreads({
    required String userId,
  }) async => Result.success(<ChatThreadPreview>[]);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
