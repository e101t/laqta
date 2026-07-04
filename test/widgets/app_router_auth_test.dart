import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:laqta/app/router/app_router.dart';
import 'package:laqta/core/localization/app_localizations.dart';
import 'package:laqta/core/services/backend_session_service.dart';
import 'package:laqta/features/auth/presentation/screens/auth_screen.dart';
import 'package:laqta/features/onboarding/presentation/screens/onboarding_screen.dart';

class MockBackendSessionService extends Mock implements BackendSessionService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    AppRouter.setSessionServiceOverride(null);
    AppRouter.setSplashDelayCompleteForTest(false);
  });

  testWidgets('routes to auth when signed out', (tester) async {
    SharedPreferences.setMockInitialValues({
      'language': 'en',
      'onboarding_seen': true,
    });

    final session = MockBackendSessionService();
    when(() => session.hasValidToken()).thenAnswer((_) async => false);
    when(() => session.getUserId()).thenAnswer((_) async => null);

    AppRouter.setSessionServiceOverride(session);
    AppRouter.setSplashDelayCompleteForTest(true);
    final router = AppRouter.createRouter(sessionOverride: session);

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        locale: const Locale('en'),
        supportedLocales: const [Locale('en')],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(AuthScreen), findsOneWidget);
  });

  testWidgets('routes to onboarding once after language selection', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'language': 'en'});

    final session = MockBackendSessionService();
    when(() => session.hasValidToken()).thenAnswer((_) async => false);
    when(() => session.getUserId()).thenAnswer((_) async => null);

    AppRouter.setSessionServiceOverride(session);
    AppRouter.setSplashDelayCompleteForTest(true);
    final router = AppRouter.createRouter(sessionOverride: session);

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        locale: const Locale('en'),
        supportedLocales: const [Locale('en')],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(OnboardingScreen), findsOneWidget);
  });
}
