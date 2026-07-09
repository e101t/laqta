import 'package:flutter_test/flutter_test.dart';
import 'package:laqta/features/dashboard/presentation/screens/customer_dashboard_screen.dart';
import '../helpers/test_app.dart';

void main() {
  testWidgets('customer dashboard renders luxury home feed shell', (
    tester,
  ) async {
    await tester.pumpWidget(wrapWithMaterial(const CustomerDashboardScreen()));
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('LAQTA'), findsOneWidget);
    expect(find.text('Search for a photographer, venue, place...'), findsOneWidget);
    expect(find.text('Places'), findsOneWidget);
    expect(find.text('Venues'), findsOneWidget);
    expect(find.text('Photographers'), findsOneWidget);
    expect(find.text('Follow'), findsOneWidget);
    expect(find.text('For you'), findsOneWidget);
    expect(find.text('Most viewed'), findsOneWidget);
    expect(find.text('Sessions'), findsOneWidget);
    expect(find.text('Weddings'), findsOneWidget);
    expect(find.text('جلسة في الطبيعة'), findsNothing);
    expect(find.text('قاعة رويال لايف'), findsNothing);
  });

  testWidgets(
    'customer dashboard switching tabs does not require mock feed rows',
    (tester) async {
      await tester.pumpWidget(
        wrapWithMaterial(const CustomerDashboardScreen()),
      );
      await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.text('Sessions'));
      await tester.pump();
      await tester.tap(find.text('Weddings'));
      await tester.pump();
      await tester.tap(find.text('For you'));
      await tester.pump();

      expect(find.text('جلسة في الطبيعة'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
