import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:laqta/core/domain/result/result.dart';
import 'package:laqta/core/domain/failures/failure.dart';
import 'package:laqta/features/auth/auth_dependencies.dart';
import 'package:laqta/features/auth/domain/entities/auth_user.dart';
import 'package:laqta/features/booking/booking_dependencies.dart';
import 'package:laqta/features/booking/domain/entities/booking.dart';
import 'package:laqta/core/localization/app_localizations.dart';
import 'package:laqta/features/dashboard/presentation/screens/customer_dashboard_screen.dart';
import '../helpers/mocks.dart';
import '../helpers/test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  registerFallbacks();

  tearDown(() {
    AuthDependencies.setRepositoryOverride(null);
    BookingDependencies.setRepositoryOverride(null);
  });

  testWidgets('shows empty states and create request CTA', (tester) async {
    final authRepo = MockAuthRepository();
    final bookingRepo = MockBookingRepository();

    AuthDependencies.setRepositoryOverride(authRepo);
    BookingDependencies.setRepositoryOverride(bookingRepo);

    when(() => authRepo.getCurrentUser()).thenAnswer(
      (_) async =>
          Result.success(AuthUser(id: 'user1', isAnonymous: false)),
    );
    when(() => bookingRepo.getMyBookings(userId: 'user1')).thenAnswer(
      (_) async => Result.success(<Booking>[]),
    );

    await tester.pumpWidget(wrapWithMaterial(const CustomerDashboardScreen()));
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(CustomerDashboardScreen));
    final localizations = AppLocalizations.of(context);

    expect(
      find.text(localizations.createRequest, skipOffstage: false),
      findsOneWidget,
    );

    final mainList = find.byWidgetPredicate(
      (widget) => widget is ListView && widget.scrollDirection == Axis.vertical,
    );

    await tester.dragUntilVisible(
      find.text(localizations.noProducts),
      mainList,
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();
    expect(
      find.text(localizations.noProducts, skipOffstage: false),
      findsOneWidget,
    );

    await tester.dragUntilVisible(
      find.text(localizations.noBookings),
      mainList,
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();
    expect(
      find.text(localizations.noBookings, skipOffstage: false),
      findsOneWidget,
    );
  });

  testWidgets('shows error state when auth load fails', (tester) async {
    final authRepo = MockAuthRepository();
    final bookingRepo = MockBookingRepository();

    AuthDependencies.setRepositoryOverride(authRepo);
    BookingDependencies.setRepositoryOverride(bookingRepo);

    when(() => authRepo.getCurrentUser()).thenAnswer(
      (_) async => Result.failure(Failure(message: 'auth failed')),
    );
    when(() => bookingRepo.getMyBookings(userId: 'user1')).thenAnswer(
      (_) async => Result.success(<Booking>[]),
    );

    await tester.pumpWidget(wrapWithMaterial(const CustomerDashboardScreen()));
    await tester.pumpAndSettle();

    expect(find.text('حدث خطأ'), findsOneWidget);
  });

  testWidgets('async load after dispose does not crash', (tester) async {
    final authRepo = MockAuthRepository();
    final bookingRepo = MockBookingRepository();

    AuthDependencies.setRepositoryOverride(authRepo);
    BookingDependencies.setRepositoryOverride(bookingRepo);

    final completer = Completer<Result<List<Booking>>>();

    when(() => authRepo.getCurrentUser()).thenAnswer(
      (_) async =>
          Result.success(AuthUser(id: 'user1', isAnonymous: false)),
    );
    when(() => bookingRepo.getMyBookings(userId: 'user1'))
        .thenAnswer((_) => completer.future);

    await tester.pumpWidget(wrapWithMaterial(const CustomerDashboardScreen()));
    await tester.pump();

    await tester.pumpWidget(wrapWithMaterial(const SizedBox.shrink()));
    await tester.pump();

    completer.complete(Result.success(<Booking>[]));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
