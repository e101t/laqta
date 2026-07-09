import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laqta/features/auth/auth_dependencies.dart';
import 'package:laqta/features/auth/presentation/screens/auth_screen.dart';

import '../helpers/mocks.dart';
import '../helpers/test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    AuthDependencies.setRepositoryOverride(null);
  });

  testWidgets('auth screen opens with password login', (tester) async {
    AuthDependencies.setRepositoryOverride(MockAuthRepository());

    await tester.pumpWidget(wrapWithMaterial(const AuthScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Welcome to Laqta'), findsOneWidget);
    expect(find.text('Phone number or username'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
    expect(
      find.textContaining('Create account', findRichText: true),
      findsOneWidget,
    );
  });

  testWidgets('registration wizard opens with the four-step role flow', (
    tester,
  ) async {
    AuthDependencies.setRepositoryOverride(MockAuthRepository());

    await tester.pumpWidget(wrapWithMaterial(const AuthScreen()));
    await tester.pumpAndSettle();

    final registerButton = find.byType(TextButton).last;
    await tester.ensureVisible(registerButton);
    await tester.tap(registerButton);
    await tester.pumpAndSettle();

    expect(find.text('Step 1 of 4'), findsOneWidget);
    expect(find.text('Choose account type'), findsOneWidget);
    expect(find.text('Customer'), findsOneWidget);
    expect(find.text('Photographer'), findsOneWidget);
    expect(find.text('Venue owner'), findsOneWidget);
    expect(
      find.textContaining('Sign in', findRichText: true),
      findsOneWidget,
    );
  });
}
