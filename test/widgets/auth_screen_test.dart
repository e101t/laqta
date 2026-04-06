import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:laqta/core/domain/result/result.dart';
import 'package:laqta/core/widgets/iraqi_phone_number_field.dart';
import 'package:laqta/features/auth/auth_dependencies.dart';
import 'package:laqta/features/auth/presentation/screens/auth_screen.dart';

import '../helpers/mocks.dart';
import '../helpers/test_app.dart';

Future<void> enterPhoneFromPicker(WidgetTester tester, String phoneNumber) async {
  await tester.tap(find.byType(IraqiPhoneNumberField));
  await tester.pumpAndSettle();

  for (final digit in phoneNumber.split('')) {
    await tester.tap(find.text(digit).last);
    await tester.pump();
  }

  await tester.tap(find.text('Done'));
  await tester.pumpAndSettle();
}

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

    await enterPhoneFromPicker(tester, '07700000000');
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

    await enterPhoneFromPicker(tester, '07700000000');
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).last, '123');
    await tester.ensureVisible(find.text('Verify'));
    await tester.tap(find.text('Verify'));
    await tester.pump(const Duration(milliseconds: 100));

    expect(
      find.text('Please enter a valid verification code'),
      findsOneWidget,
    );
  });
}
