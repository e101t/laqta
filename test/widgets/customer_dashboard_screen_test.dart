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
    expect(find.text('ابحث عن مصور، قاعة، مكان...'), findsOneWidget);
    expect(find.text('الأماكن'), findsOneWidget);
    expect(find.text('القاعات'), findsOneWidget);
    expect(find.text('المصورين'), findsOneWidget);
    expect(find.text('تابع'), findsOneWidget);
    expect(find.text('لك'), findsOneWidget);
    expect(find.text('الأكثر مشاهدة'), findsOneWidget);
    expect(find.text('جلسات'), findsOneWidget);
    expect(find.text('زفاف'), findsOneWidget);
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

      await tester.tap(find.text('جلسات'));
      await tester.pump();
      await tester.tap(find.text('زفاف'));
      await tester.pump();
      await tester.tap(find.text('لك'));
      await tester.pump();

      expect(find.text('جلسة في الطبيعة'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
