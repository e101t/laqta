import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laqta/core/widgets/empty_states.dart';
import 'package:laqta/features/requests/requests_dependencies.dart';
import 'package:laqta/features/requests/presentation/screens/create_request_screen.dart';
import 'package:laqta/features/store/presentation/screens/store_screen.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/mocks.dart';
import '../helpers/test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    RequestsDependencies.setRepositoryOverride(null);
  });

  testWidgets('store shows curated products instead of empty state', (
    tester,
  ) async {
    await tester.pumpWidget(wrapWithMaterial(const StoreScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Featured Products'), findsNWidgets(2));
    expect(find.byIcon(Icons.shopping_bag_outlined), findsNWidgets(3));
    expect(find.byType(EmptyState), findsNothing);
  });

  testWidgets('store order action opens create request flow', (tester) async {
    final requestsRepo = MockRequestsRepository();
    RequestsDependencies.setRepositoryOverride(requestsRepo);
    when(() => requestsRepo.generateRequestId()).thenReturn('req_store_test');
    tester.view.physicalSize = const Size(1200, 2200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(wrapWithMaterial(const StoreScreen()));
    await tester.pumpAndSettle();

    final orderButton = find
        .byIcon(Icons.shopping_bag_outlined)
        .hitTestable()
        .first;
    await tester.tap(orderButton, warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.byType(CreateRequestScreen), findsOneWidget);
    expect(find.text('Create Request'), findsOneWidget);
  });
}
