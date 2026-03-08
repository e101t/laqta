import 'package:flutter_test/flutter_test.dart';
import 'package:luqta/features/payment/presentation/screens/payment_screen.dart';

import '../helpers/test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('shows unavailable copy when payments disabled', (tester) async {
    await tester.pumpWidget(
      wrapWithMaterial(
        const PaymentScreen(
          bookingId: 'book1',
          amount: 100000,
          photographerName: 'Photographer',
          sessionType: 'Wedding',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Payments are coming soon'), findsOneWidget);
  });
}
