import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:luqta/core/domain/result/result.dart';
import 'package:luqta/features/auth/auth_dependencies.dart';
import 'package:luqta/features/auth/presentation/screens/auth_screen.dart';

import '../helpers/mocks.dart';
import '../helpers/test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    AuthDependencies.setRepositoryOverride(null);
  });

  testWidgets('phone auth shows OTP after code sent', (tester) async {
    final authRepo = MockAuthRepository();
    AuthDependencies.setRepositoryOverride(authRepo);

    when(
      () => authRepo.verifyPhoneNumber(
        phoneNumber: any(named: 'phoneNumber'),
        onCodeSent: any(named: 'onCodeSent'),
        onVerificationCompleted: any(named: 'onVerificationCompleted'),
        onVerificationFailed: any(named: 'onVerificationFailed'),
        onCodeAutoRetrievalTimeout: any(named: 'onCodeAutoRetrievalTimeout'),
      ),
    ).thenAnswer((invocation) async {
      final onCodeSent =
          invocation.namedArguments[#onCodeSent] as void Function(String, int?);
      onCodeSent('verif123', null);
      return Result.success(null);
    });

    await tester.pumpWidget(wrapWithMaterial(const AuthScreen()));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Sign in with Phone'));
    await tester.tap(find.text('Sign in with Phone'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), '+964 770 000 0000');
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Verify Code'), findsOneWidget);
  });

  testWidgets('invalid OTP shows validation message', (tester) async {
    final authRepo = MockAuthRepository();
    AuthDependencies.setRepositoryOverride(authRepo);

    when(
      () => authRepo.verifyPhoneNumber(
        phoneNumber: any(named: 'phoneNumber'),
        onCodeSent: any(named: 'onCodeSent'),
        onVerificationCompleted: any(named: 'onVerificationCompleted'),
        onVerificationFailed: any(named: 'onVerificationFailed'),
        onCodeAutoRetrievalTimeout: any(named: 'onCodeAutoRetrievalTimeout'),
      ),
    ).thenAnswer((invocation) async {
      final onCodeSent =
          invocation.namedArguments[#onCodeSent] as void Function(String, int?);
      onCodeSent('verif123', null);
      return Result.success(null);
    });

    await tester.pumpWidget(wrapWithMaterial(const AuthScreen()));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Sign in with Phone'));
    await tester.tap(find.text('Sign in with Phone'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), '+964 770 000 0000');
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, '123');
    await tester.ensureVisible(find.text('Verify'));
    await tester.tap(find.text('Verify'));
    await tester.pump(const Duration(milliseconds: 100));

    expect(
      find.text('Please enter a valid verification code'),
      findsOneWidget,
    );
  });
}
