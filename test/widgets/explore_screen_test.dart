import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:luqta/core/domain/result/result.dart';
import 'package:luqta/features/auth/auth_dependencies.dart';
import 'package:luqta/features/auth/domain/entities/auth_user.dart';
import 'package:luqta/features/explore/presentation/screens/explore_screen.dart';
import 'package:luqta/features/profile/domain/entities/user_profile.dart';
import 'package:luqta/features/profile/profile_dependencies.dart';
import 'package:luqta/features/reels/domain/entities/reel_model.dart';
import 'package:luqta/features/reels/reels_dependencies.dart';
import 'package:luqta/features/search/domain/entities/search_result_photographer.dart';
import 'package:luqta/features/search/search_dependencies.dart';
import 'package:luqta/core/widgets/empty_states.dart';
import 'package:luqta/core/widgets/photographer_card.dart';
import 'package:luqta/core/widgets/post_card.dart';
import '../helpers/mocks.dart';
import '../helpers/test_app.dart';

Future<Set<String>> _emptyFollowing(String userId) async => const {};

Finder _verticalScrollable() {
  return find.byWidgetPredicate(
    (widget) =>
        widget is Scrollable && widget.axisDirection == AxisDirection.down,
  );
}

Future<void> _scrollUntilFound(WidgetTester tester, Finder finder) async {
  final scrollable = _verticalScrollable();
  for (var i = 0; i < 6 && finder.evaluate().isEmpty; i += 1) {
    await tester.drag(scrollable, const Offset(0, -600));
    await tester.pumpAndSettle();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  registerFallbacks();

  tearDown(() {
    AuthDependencies.setRepositoryOverride(null);
    ProfileDependencies.setRepositoryOverride(null);
    ReelsDependencies.setRepositoryOverride(null);
    SearchDependencies.setRepositoryOverride(null);
  });

  testWidgets('shows empty states when no explore data', (tester) async {
    final authRepo = MockAuthRepository();
    final profileRepo = MockProfileRepository();
    final reelsRepo = MockReelsRepository();
    final searchRepo = MockSearchRepository();

    AuthDependencies.setRepositoryOverride(authRepo);
    ProfileDependencies.setRepositoryOverride(profileRepo);
    ReelsDependencies.setRepositoryOverride(reelsRepo);
    SearchDependencies.setRepositoryOverride(searchRepo);

    when(() => authRepo.getCurrentUser()).thenAnswer(
      (_) async => Result.success(AuthUser(id: 'user1', isAnonymous: false)),
    );
    when(() => profileRepo.getUserProfile(userId: 'user1')).thenAnswer(
      (_) async => Result.success(
        UserProfile(
          id: 'user1',
          role: 'customer',
          name: 'User',
          governorate: 'Baghdad',
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
        ),
      ),
    );
    when(
      () => reelsRepo.getReels(),
    ).thenAnswer((_) async => Result.success(<ReelModel>[]));
    when(
      () => searchRepo.searchPhotographers(query: any(named: 'query')),
    ).thenAnswer((_) async => Result.success(<SearchResultPhotographer>[]));

    await tester.pumpWidget(
      wrapWithMaterial(
        ExploreScreen(
          fetchFollowingOverride: _emptyFollowing,
          submitReportOverride:
              ({
                required reporterId,
                required targetId,
                required targetType,
                required targetOwnerId,
                required reason,
              }) async {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(PhotographerCard), findsNothing);
    expect(find.byType(PostCard), findsNothing);
    expect(find.byType(EmptyState), findsNWidgets(2));
  });

  testWidgets('report action shows success snackbar', (tester) async {
    final authRepo = MockAuthRepository();
    final profileRepo = MockProfileRepository();
    final reelsRepo = MockReelsRepository();
    final searchRepo = MockSearchRepository();

    AuthDependencies.setRepositoryOverride(authRepo);
    ProfileDependencies.setRepositoryOverride(profileRepo);
    ReelsDependencies.setRepositoryOverride(reelsRepo);
    SearchDependencies.setRepositoryOverride(searchRepo);

    when(() => authRepo.getCurrentUser()).thenAnswer(
      (_) async => Result.success(AuthUser(id: 'user1', isAnonymous: false)),
    );
    when(() => profileRepo.getUserProfile(userId: 'user1')).thenAnswer(
      (_) async => Result.success(
        UserProfile(
          id: 'user1',
          role: 'customer',
          name: 'User',
          governorate: 'Baghdad',
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
        ),
      ),
    );
    when(() => reelsRepo.getReels()).thenAnswer(
      (_) async => Result.success([
        ReelModel(
          reelId: 'reel1',
          photographerId: 'photog1',
          photographerName: 'Photographer',
          videoUrl: 'https://example.com/video.mp4',
          thumbnailUrl: 'https://example.com/thumb.jpg',
          caption: 'Caption',
          createdAt: DateTime(2026, 1, 1),
        ),
      ]),
    );
    when(
      () => searchRepo.searchPhotographers(query: any(named: 'query')),
    ).thenAnswer((_) async => Result.success(<SearchResultPhotographer>[]));

    await tester.pumpWidget(
      wrapWithMaterial(
        ExploreScreen(
          fetchFollowingOverride: _emptyFollowing,
          submitReportOverride:
              ({
                required reporterId,
                required targetId,
                required targetType,
                required targetOwnerId,
                required reason,
              }) async {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    final reportButton = find.byIcon(Icons.flag_outlined).last;
    await _scrollUntilFound(tester, reportButton);
    await tester.ensureVisible(reportButton);
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.flag_outlined), findsOneWidget);
    await tester.tap(reportButton, warnIfMissed: false);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(ListTile).first);
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsOneWidget);
  });

  testWidgets('report action shows error snackbar on failure', (tester) async {
    final authRepo = MockAuthRepository();
    final profileRepo = MockProfileRepository();
    final reelsRepo = MockReelsRepository();
    final searchRepo = MockSearchRepository();

    AuthDependencies.setRepositoryOverride(authRepo);
    ProfileDependencies.setRepositoryOverride(profileRepo);
    ReelsDependencies.setRepositoryOverride(reelsRepo);
    SearchDependencies.setRepositoryOverride(searchRepo);

    when(() => authRepo.getCurrentUser()).thenAnswer(
      (_) async => Result.success(AuthUser(id: 'user1', isAnonymous: false)),
    );
    when(() => profileRepo.getUserProfile(userId: 'user1')).thenAnswer(
      (_) async => Result.success(
        UserProfile(
          id: 'user1',
          role: 'customer',
          name: 'User',
          governorate: 'Baghdad',
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
        ),
      ),
    );
    when(() => reelsRepo.getReels()).thenAnswer(
      (_) async => Result.success([
        ReelModel(
          reelId: 'reel1',
          photographerId: 'photog1',
          photographerName: 'Photographer',
          videoUrl: 'https://example.com/video.mp4',
          thumbnailUrl: 'https://example.com/thumb.jpg',
          caption: 'Caption',
          createdAt: DateTime(2026, 1, 1),
        ),
      ]),
    );
    when(
      () => searchRepo.searchPhotographers(query: any(named: 'query')),
    ).thenAnswer((_) async => Result.success(<SearchResultPhotographer>[]));

    await tester.pumpWidget(
      wrapWithMaterial(
        ExploreScreen(
          fetchFollowingOverride: _emptyFollowing,
          submitReportOverride:
              ({
                required reporterId,
                required targetId,
                required targetType,
                required targetOwnerId,
                required reason,
              }) async {
                throw StateError('failed');
              },
        ),
      ),
    );
    await tester.pumpAndSettle();

    final reportButton = find.byIcon(Icons.flag_outlined).last;
    await _scrollUntilFound(tester, reportButton);
    await tester.ensureVisible(reportButton);
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.flag_outlined), findsOneWidget);
    await tester.tap(reportButton, warnIfMissed: false);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(ListTile).first);
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsOneWidget);
  });

  testWidgets('opening comments and closing does not crash', (tester) async {
    final authRepo = MockAuthRepository();
    final profileRepo = MockProfileRepository();
    final reelsRepo = MockReelsRepository();
    final searchRepo = MockSearchRepository();

    AuthDependencies.setRepositoryOverride(authRepo);
    ProfileDependencies.setRepositoryOverride(profileRepo);
    ReelsDependencies.setRepositoryOverride(reelsRepo);
    SearchDependencies.setRepositoryOverride(searchRepo);

    when(() => authRepo.getCurrentUser()).thenAnswer(
      (_) async => Result.success(AuthUser(id: 'user1', isAnonymous: false)),
    );
    when(() => profileRepo.getUserProfile(userId: 'user1')).thenAnswer(
      (_) async => Result.success(
        UserProfile(
          id: 'user1',
          role: 'customer',
          name: 'User',
          governorate: 'Baghdad',
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
        ),
      ),
    );
    when(() => reelsRepo.getReels()).thenAnswer(
      (_) async => Result.success([
        ReelModel(
          reelId: 'reel1',
          photographerId: 'photog1',
          photographerName: 'Photographer',
          videoUrl: 'https://example.com/video.mp4',
          thumbnailUrl: 'https://example.com/thumb.jpg',
          caption: 'Caption',
          createdAt: DateTime(2026, 1, 1),
        ),
      ]),
    );
    when(
      () => reelsRepo.getComments(reelId: any(named: 'reelId')),
    ).thenAnswer((_) async => Result.success([]));
    when(
      () => searchRepo.searchPhotographers(query: any(named: 'query')),
    ).thenAnswer((_) async => Result.success(<SearchResultPhotographer>[]));

    await tester.pumpWidget(
      wrapWithMaterial(
        ExploreScreen(
          fetchFollowingOverride: _emptyFollowing,
          submitReportOverride:
              ({
                required reporterId,
                required targetId,
                required targetType,
                required targetOwnerId,
                required reason,
              }) async {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    final commentButton = find.byIcon(Icons.chat_bubble_outline).last;
    await _scrollUntilFound(tester, commentButton);
    await tester.ensureVisible(commentButton);
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.chat_bubble_outline), findsOneWidget);
    await tester.tap(commentButton, warnIfMissed: false);
    await tester.pumpAndSettle();

    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
