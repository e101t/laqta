import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:laqta/app/router/app_router.dart';
import 'package:laqta/core/localization/app_localizations.dart';
import 'package:laqta/core/domain/result/result.dart';
import 'package:laqta/features/auth/auth_dependencies.dart';
import 'package:laqta/features/auth/domain/entities/auth_user.dart';
import 'package:laqta/features/profile/domain/entities/user_profile.dart';
import 'package:laqta/features/profile/profile_dependencies.dart';
import 'package:laqta/features/profile/presentation/screens/basic_info_screen.dart';

import '../helpers/mocks.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    AppRouter.setAuthOverride(null);
    AppRouter.setSplashDelayCompleteForTest(false);
    AppRouter.invalidateProfileCache();
    AuthDependencies.setRepositoryOverride(null);
    ProfileDependencies.setRepositoryOverride(null);
  });

  testWidgets('signed in without role routes to basic info', (tester) async {
    SharedPreferences.setMockInitialValues({'language': 'en'});

    final auth = MockFirebaseAuth();
    final user = MockUser();
    final profileRepo = MockProfileRepository();
    final authRepo = MockAuthRepository();

    when(() => user.uid).thenReturn('user1');
    when(() => auth.currentUser).thenReturn(user);
    when(() => auth.authStateChanges()).thenAnswer((_) => Stream.value(user));

    when(() => profileRepo.getUserProfile(userId: 'user1')).thenAnswer(
      (_) async => Result.success(
        UserProfile(
          id: 'user1',
          role: '',
          name: 'User',
          governorate: 'Baghdad',
          profileCompleted: false,
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
        ),
      ),
    );

    AppRouter.setAuthOverride(auth);
    AppRouter.setSplashDelayCompleteForTest(true);
    ProfileDependencies.setRepositoryOverride(profileRepo);
    AuthDependencies.setRepositoryOverride(authRepo);
    when(() => authRepo.getCurrentUser()).thenAnswer(
      (_) async => Result.success(AuthUser(id: 'user1', isAnonymous: false)),
    );

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

    expect(find.byType(BasicInfoScreen), findsOneWidget);
  });

  testWidgets('signed in with role routes to basic info', (tester) async {
    SharedPreferences.setMockInitialValues({'language': 'en'});

    final auth = MockFirebaseAuth();
    final user = MockUser();
    final profileRepo = MockProfileRepository();
    final authRepo = MockAuthRepository();

    when(() => user.uid).thenReturn('user1');
    when(() => auth.currentUser).thenReturn(user);
    when(() => auth.authStateChanges()).thenAnswer((_) => Stream.value(user));

    when(() => profileRepo.getUserProfile(userId: 'user1')).thenAnswer(
      (_) async => Result.success(
        UserProfile(
          id: 'user1',
          role: 'customer',
          name: 'User',
          governorate: 'Baghdad',
          profileCompleted: false,
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
        ),
      ),
    );

    AppRouter.setAuthOverride(auth);
    AppRouter.setSplashDelayCompleteForTest(true);
    ProfileDependencies.setRepositoryOverride(profileRepo);
    AuthDependencies.setRepositoryOverride(authRepo);
    when(() => authRepo.getCurrentUser()).thenAnswer(
      (_) async => Result.success(AuthUser(id: 'user1', isAnonymous: false)),
    );

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

    expect(find.byType(BasicInfoScreen), findsOneWidget);
  });

  // Full main app routing is covered in integration_test/app_flow_test.dart.
}
