import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laqta/core/localization/app_localizations.dart';
import 'package:laqta/core/constants/app_constants.dart';
import 'package:laqta/core/models/booking_model.dart';
import 'package:laqta/features/booking/presentation/screens/booking_details_screen.dart';
import '../helpers/test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  BookingModel buildBooking({
    required String status,
    required String customerId,
    required String photographerId,
    int revisionCount = 0,
  }) {
    return BookingModel(
      id: 'booking1',
      customerId: customerId,
      photographerId: photographerId,
      date: '2026-02-01',
      time: '10:00',
      duration: 60,
      type: 'Wedding',
      price: 100,
      status: status,
      payment: PaymentInfo(),
      location: LocationInfo(),
      deliverables: DeliverablesInfo(),
      revisionCount: revisionCount,
      timeline: BookingTimeline(),
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );
  }

  testWidgets('photographer sees start job action for confirmed booking', (
    tester,
  ) async {
    final booking = buildBooking(
      status: AppConstants.bookingConfirmed,
      customerId: 'cust1',
      photographerId: 'photog1',
    );

    await tester.pumpWidget(
      wrapWithMaterial(
        BookingDetailsScreen(
          bookingId: booking.id,
          initialBooking: booking,
          currentUserIdOverride: 'photog1',
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -800));
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(BookingDetailsScreen));
    final localizations = AppLocalizations.of(context);
    expect(
      find.text(localizations.startJob, skipOffstage: false),
      findsOneWidget,
    );
  });

  testWidgets('customer sees accept delivery and request revision actions', (
    tester,
  ) async {
    final booking = buildBooking(
      status: AppConstants.bookingDelivered,
      customerId: 'cust1',
      photographerId: 'photog1',
    );

    await tester.pumpWidget(
      wrapWithMaterial(
        BookingDetailsScreen(
          bookingId: booking.id,
          initialBooking: booking,
          currentUserIdOverride: 'cust1',
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -800));
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(BookingDetailsScreen));
    final localizations = AppLocalizations.of(context);
    expect(
      find.text(localizations.acceptDelivery, skipOffstage: false),
      findsOneWidget,
    );
    expect(
      find.text(localizations.requestRevision, skipOffstage: false),
      findsOneWidget,
    );
  });
}
