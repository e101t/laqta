import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laqta/core/domain/result/result.dart';
import 'package:laqta/core/localization/app_localizations.dart';
import 'package:laqta/features/auth/auth_dependencies.dart';
import 'package:laqta/features/auth/domain/entities/auth_user.dart';
import 'package:laqta/features/auth/domain/repositories/auth_repository.dart';
import 'package:laqta/features/notifications/notifications_dependencies.dart';
import 'package:laqta/features/notifications/presentation/screens/notifications_screen.dart';

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

      final context = tester.element(find.byType(NotificationsScreen));
      final localizations = AppLocalizations.of(context);

      expect(find.text(localizations.userNotAuthenticated), findsOneWidget);
      expect(find.text(localizations.retry), findsOneWidget);
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
