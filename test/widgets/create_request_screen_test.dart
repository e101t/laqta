import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:laqta/core/domain/result/result.dart';
import 'package:laqta/features/auth/auth_dependencies.dart';
import 'package:laqta/features/auth/domain/entities/auth_user.dart';
import 'package:laqta/features/requests/requests_dependencies.dart';
import 'package:laqta/features/requests/domain/entities/photo_request.dart';
import 'package:laqta/features/requests/domain/entities/request_deliverables.dart';
import 'package:laqta/features/requests/presentation/screens/create_request_screen.dart';
import 'package:laqta/features/requests/presentation/screens/select_location_screen.dart';
import '../helpers/mocks.dart';
import '../helpers/test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  registerFallbacks();

  tearDown(() {
    AuthDependencies.setRepositoryOverride(null);
    RequestsDependencies.setRepositoryOverride(null);
  });

  testWidgets('shows validation error for past date/time', (tester) async {
    final authRepo = MockAuthRepository();
    final requestsRepo = MockRequestsRepository();
    AuthDependencies.setRepositoryOverride(authRepo);
    RequestsDependencies.setRepositoryOverride(requestsRepo);

    when(() => authRepo.getCurrentUser()).thenAnswer(
      (_) async => Result.success(AuthUser(id: 'user1', isAnonymous: false)),
    );
    when(() => requestsRepo.generateRequestId()).thenReturn('req1');

    final initialRequest = PhotoRequest(
      id: 'req1',
      clientId: 'user1',
      type: 'Wedding',
      date: '2025-01-01',
      time: '09:00',
      governorate: 'Baghdad',
      durationHours: 2,
      deliverables: const RequestDeliverables(),
      referenceImages: const [],
      status: 'draft',
      offersCount: 0,
      createdAt: DateTime(2025, 1, 1),
      updatedAt: DateTime(2025, 1, 1),
    );

    await tester.pumpWidget(
      wrapWithMaterial(CreateRequestScreen(initialRequest: initialRequest)),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Publish Request'));
    await tester.tap(find.text('Publish Request'));
    await tester.pumpAndSettle();

    expect(find.text('Please select a future date and time'), findsOneWidget);
  });

  testWidgets('selecting location updates button label', (tester) async {
    final authRepo = MockAuthRepository();
    final requestsRepo = MockRequestsRepository();
    AuthDependencies.setRepositoryOverride(authRepo);
    RequestsDependencies.setRepositoryOverride(requestsRepo);

    when(() => authRepo.getCurrentUser()).thenAnswer(
      (_) async => Result.success(AuthUser(id: 'user1', isAnonymous: false)),
    );
    when(() => requestsRepo.generateRequestId()).thenReturn('req1');

    Future<LocationSelectionResult?> fakePicker(
      BuildContext context,
      LatLng? currentPosition,
      String? currentLabel,
      String? governorate,
    ) async {
      return LocationSelectionResult(
        position: const LatLng(33.3128, 44.3615),
        label: 'Baghdad',
      );
    }

    await tester.pumpWidget(
      wrapWithMaterial(
        CreateRequestScreen(
          prefillType: 'Wedding',
          prefillStyle: 'Classic',
          locationPicker: fakePicker,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byIcon(Icons.map));
    await tester.tap(find.byIcon(Icons.map));
    await tester.pumpAndSettle();

    expect(find.text('Location selected'), findsOneWidget);
  });

  testWidgets(
    'editing a request uses submit callback instead of pushing details',
    (tester) async {
      final authRepo = MockAuthRepository();
      final requestsRepo = MockRequestsRepository();
      AuthDependencies.setRepositoryOverride(authRepo);
      RequestsDependencies.setRepositoryOverride(requestsRepo);

      when(() => authRepo.getCurrentUser()).thenAnswer(
        (_) async => Result.success(AuthUser(id: 'user1', isAnonymous: false)),
      );
      when(
        () => requestsRepo.updateRequest(
          requestId: any(named: 'requestId'),
          updates: any(named: 'updates'),
        ),
      ).thenAnswer((_) async => Result<void>.success(null));

      var submittedRequestId = '';
      final initialRequest = PhotoRequest(
        id: 'req_edit',
        clientId: 'user1',
        type: 'Wedding',
        date: '2026-12-31',
        time: '09:00',
        governorate: 'النجف',
        durationHours: 2,
        style: 'Classic',
        deliverables: const RequestDeliverables(),
        referenceImages: const [],
        status: 'awaiting_offers',
        offersCount: 0,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      await tester.pumpWidget(
        wrapWithMaterial(
          CreateRequestScreen(
            initialRequest: initialRequest,
            onRequestSubmitted: (requestId) => submittedRequestId = requestId,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Save changes'));
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();

      expect(submittedRequestId, 'req_edit');
    },
  );
}
