import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luqta/core/domain/result/result.dart';
import 'package:luqta/core/localization/app_localizations.dart';
import 'package:luqta/features/auth/auth_dependencies.dart';
import 'package:luqta/features/auth/domain/entities/auth_user.dart';
import 'package:luqta/features/auth/domain/repositories/auth_repository.dart';
import 'package:luqta/features/notifications/notifications_dependencies.dart';
import 'package:luqta/features/notifications/presentation/screens/notifications_screen.dart';

void main() {
  tearDown(() {
    AuthDependencies.setRepositoryOverride(null);
    NotificationsDependencies.setRepositoryOverride(null);
  });

  testWidgets(
    'notifications screen localizes unauthenticated error in Arabic',
    (tester) async {
      AuthDependencies.setRepositoryOverride(_NullAuthRepository());

      await tester.pumpWidget(
        MaterialApp(
          home: const NotificationsScreen(),
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

      expect(find.text('المستخدم غير مسجل الدخول'), findsOneWidget);
      expect(find.text('إعادة المحاولة'), findsOneWidget);
    },
  );
}

class _NullAuthRepository implements AuthRepository {
  @override
  Future<Result<AuthUser?>> getCurrentUser() async =>
      Result<AuthUser?>.success(null);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
