import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laqta/features/photographer/presentation/screens/availability_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('availability settings save locally', (tester) async {
    await tester.pumpWidget(wrapWithMaterial(const AvailabilityScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Weekly Template'), findsOneWidget);

    final saveButton = find.byKey(const Key('availability-save-button'));
    await tester.scrollUntilVisible(saveButton, 200);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(find.text('Availability saved on this device'), findsOneWidget);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('photographer_availability_v1'), isNotNull);
  });
}
