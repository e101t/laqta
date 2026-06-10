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

    expect(find.text('مرحباً بك في LAQTA'), findsOneWidget);
    expect(find.text('رقم الهاتف أو اسم المستخدم'), findsOneWidget);
    expect(find.text('تسجيل الدخول'), findsOneWidget);
    expect(
      find.textContaining('إنشاء حساب', findRichText: true),
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

    expect(find.text('الخطوة 1 من 4'), findsOneWidget);
    expect(find.text('اختر نوع الحساب'), findsOneWidget);
    expect(find.text('عميل'), findsOneWidget);
    expect(find.text('مصور'), findsOneWidget);
    expect(find.text('صاحب قاعة'), findsOneWidget);
    expect(
      find.textContaining('تسجيل الدخول', findRichText: true),
      findsOneWidget,
    );
  });
}
