import 'package:flutter_test/flutter_test.dart';
import 'package:luqta/core/domain/failures/failure.dart';
import 'package:luqta/core/domain/result/result.dart';
import 'package:luqta/features/auth/auth_dependencies.dart';
import 'package:luqta/features/auth/domain/entities/auth_user.dart';
import 'package:luqta/features/auth/domain/repositories/auth_repository.dart';
import 'package:luqta/features/requests/domain/entities/photo_request.dart';
import 'package:luqta/features/requests/domain/repositories/requests_repository.dart';
import 'package:luqta/features/requests/presentation/screens/photographer_requests_screen.dart';
import 'package:luqta/features/requests/requests_dependencies.dart';

import '../helpers/test_app.dart';

void main() {
  tearDown(() {
    AuthDependencies.setRepositoryOverride(null);
    RequestsDependencies.setRepositoryOverride(null);
  });

  testWidgets('photographer requests fall back to empty state on load failure', (
    tester,
  ) async {
    AuthDependencies.setRepositoryOverride(_FakeAuthRepository());
    RequestsDependencies.setRepositoryOverride(_FailingRequestsRepository());

    await tester.pumpWidget(
      wrapWithMaterial(const PhotographerRequestsScreen()),
    );
    await tester.pumpAndSettle();

    expect(find.text('No requests found'), findsOneWidget);
    expect(find.text('Check back later for new requests.'), findsOneWidget);
  });
}

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<Result<AuthUser?>> getCurrentUser() async => Result.success(null);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FailingRequestsRepository implements RequestsRepository {
  @override
  Future<Result<List<PhotoRequest>>> getOpenRequests({
    String? governorate,
  }) async =>
      Result.failure(const Failure(message: 'Failed to load open requests'));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
