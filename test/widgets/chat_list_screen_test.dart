import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luqta/core/domain/result/result.dart';
import 'package:luqta/core/localization/app_localizations.dart';
import 'package:luqta/features/auth/auth_dependencies.dart';
import 'package:luqta/features/auth/domain/entities/auth_user.dart';
import 'package:luqta/features/auth/domain/repositories/auth_repository.dart';
import 'package:luqta/features/chat/chat_dependencies.dart';
import 'package:luqta/features/chat/domain/entities/chat_thread_preview.dart';
import 'package:luqta/features/chat/domain/repositories/chat_repository.dart';
import 'package:luqta/features/chat/presentation/screens/chat_list_screen.dart';

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

    expect(find.text('لا توجد رسائل'), findsOneWidget);
    expect(find.text('ابدأ محادثة مع مصور'), findsOneWidget);
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
