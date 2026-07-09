import 'package:flutter_test/flutter_test.dart';
import 'package:laqta/features/explore/presentation/screens/explore_screen.dart';
import '../helpers/test_app.dart';

void main() {
  testWidgets(
    'explore screen renders discovery shell without mock marketplace rows',
    (tester) async {
      await tester.pumpWidget(wrapWithMaterial(const ExploreScreen()));
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Discover'), findsOneWidget);
      expect(find.text('Search for a photographer, venue, place...'), findsOneWidget);
      expect(find.text('Photographers'), findsOneWidget);
      expect(find.text('Venues'), findsOneWidget);
      expect(find.text('Photo spots'), findsOneWidget);
      expect(find.text('قاعة رويال لايف'), findsNothing);
      expect(find.text('حديقة السلام'), findsNothing);
    },
  );

  testWidgets('explore screen stays stable when backend data is unavailable', (
    tester,
  ) async {
    await tester.pumpWidget(wrapWithMaterial(const ExploreScreen()));
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Discover'), findsOneWidget);
    expect(find.text('مقهى نوفا'), findsNothing);
    expect(find.text('منتجع دجلة'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
