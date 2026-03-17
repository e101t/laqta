import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:laqta/app/router/app_router.dart';
import 'package:laqta/core/localization/app_localizations.dart';
import 'package:laqta/features/auth/presentation/screens/auth_screen.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    AppRouter.setAuthOverride(null);
    AppRouter.setSplashDelayCompleteForTest(false);
  });

  testWidgets('routes to auth when signed out', (tester) async {
    SharedPreferences.setMockInitialValues({'language': 'en'});

    final auth = MockFirebaseAuth();
    when(() => auth.authStateChanges()).thenAnswer((_) => Stream<User?>.value(null));
    when(() => auth.currentUser).thenReturn(null);

    AppRouter.setAuthOverride(auth);
    AppRouter.setSplashDelayCompleteForTest(true);
    final router = AppRouter.createRouter(authOverride: auth);

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
}
