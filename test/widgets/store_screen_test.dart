import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luqta/core/widgets/empty_states.dart';
import 'package:luqta/features/store/presentation/screens/store_screen.dart';

import '../helpers/test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('store shows curated products instead of empty state', (
    tester,
  ) async {
    await tester.pumpWidget(wrapWithMaterial(const StoreScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Featured Products'), findsNWidgets(2));
    expect(find.byType(EmptyState), findsNothing);
    expect(find.byIcon(Icons.shopping_bag_outlined), findsWidgets);
  });
}
