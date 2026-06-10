import 'package:flutter_test/flutter_test.dart';
import 'package:laqta/features/downloads/presentation/screens/download_links_screen.dart';
import '../helpers/test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('shows not available state when provider missing', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapWithMaterial(
        const DownloadLinksScreen(
          bookingId: 'booking1',
          photographerId: 'photog1',
          customerId: 'cust1',
          fileIds: [],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Download links are not available in this build.'),
      findsOneWidget,
    );
  });
}
