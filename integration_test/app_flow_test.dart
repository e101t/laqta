import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'dart:io';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:luqta/app/main_app_screen.dart';
import 'package:luqta/core/domain/result/result.dart';
import 'package:luqta/features/auth/auth_dependencies.dart';
import 'package:luqta/features/auth/domain/entities/auth_user.dart';
import 'package:luqta/features/auth/presentation/screens/auth_screen.dart';
import 'package:luqta/features/profile/domain/entities/user_profile.dart';
import 'package:luqta/features/profile/profile_dependencies.dart';
import 'package:luqta/features/requests/domain/entities/photo_request.dart';
import 'package:luqta/features/requests/domain/entities/request_offer.dart';
import 'package:luqta/features/requests/domain/repositories/requests_repository.dart';
import 'package:luqta/features/requests/presentation/screens/create_request_screen.dart';
import 'package:luqta/features/requests/presentation/screens/select_location_screen.dart';
import 'package:luqta/features/requests/presentation/screens/my_requests_screen.dart';
import 'package:luqta/features/requests/requests_dependencies.dart';
import 'package:luqta/features/booking/domain/entities/booking.dart';
import 'package:luqta/features/booking/booking_dependencies.dart';
import 'package:luqta/features/search/domain/entities/search_result_photographer.dart';
import 'package:luqta/features/search/search_dependencies.dart';
import 'package:luqta/features/reels/presentation/screens/create_post_screen.dart';
import 'package:luqta/features/reels/domain/entities/reel_model.dart';
import 'package:luqta/features/reels/reels_dependencies.dart';
import 'package:luqta/features/story/presentation/screens/create_story_screen.dart';
import 'package:luqta/features/story/story_dependencies.dart';
import 'package:luqta/features/explore/presentation/screens/explore_screen.dart';
import 'package:luqta/features/chat/chat_dependencies.dart';
import 'package:luqta/features/chat/domain/entities/chat_thread_preview.dart';
import '../test/helpers/mocks.dart';
import '../test/helpers/test_app.dart';

// Integration tests run on real codecs (unlike widget tests), so we need real
// image bytes that decode correctly on device.
final List<int> _testPngBytes = (() {
  final image = img.Image(width: 8, height: 8, numChannels: 4)
    ..clear(img.ColorUint8.rgba(255, 0, 0, 255));
  return img.encodePng(image);
})();

class InMemoryRequestsRepository implements RequestsRepository {
  final List<PhotoRequest> _requests = [];

  @override
  Future<Result<List<PhotoRequest>>> getMyRequests({
    required String clientId,
  }) async {
    return Result.success(
      _requests.where((r) => r.clientId == clientId).toList(),
    );
  }

  @override
  Future<Result<List<PhotoRequest>>> getOpenRequests({String? governorate}) async {
    return Result.success(<PhotoRequest>[]);
  }

  @override
  Future<Result<PhotoRequest>> getRequestById(String requestId) async {
    final request = _requests.firstWhere((r) => r.id == requestId);
    return Result.success(request);
  }

  @override
  Future<Result<void>> createRequest(PhotoRequest request) async {
    _requests.add(request);
    return Result.success(null);
  }

  @override
  Future<Result<void>> updateRequest({
    required String requestId,
    required Map<String, dynamic> updates,
  }) async {
    return Result.success(null);
  }

  @override
  Future<Result<List<RequestOffer>>> getOffersForRequest(String requestId) async {
    return Result.success(<RequestOffer>[]);
  }

  @override
  Future<Result<List<RequestOffer>>> getMyOffers({
    required String photographerId,
  }) async {
    return Result.success(<RequestOffer>[]);
  }

  @override
  Future<Result<void>> createOffer(RequestOffer offer) async {
    return Result.success(null);
  }

  @override
  Future<Result<void>> acceptOffer({
    required PhotoRequest request,
    required RequestOffer offer,
    required Booking booking,
  }) async {
    return Result.success(null);
  }

  @override
  Future<Result<String>> uploadReferenceImage({
    required String requestId,
    required String filePath,
  }) async {
    return Result.success('https://example.com/ref.jpg');
  }

  @override
  String generateRequestId() => 'req1';

  @override
  String generateOfferId() => 'offer1';
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  registerFallbacks();

  tearDown(() {
    AuthDependencies.setRepositoryOverride(null);
    ProfileDependencies.setRepositoryOverride(null);
    RequestsDependencies.setRepositoryOverride(null);
    BookingDependencies.setRepositoryOverride(null);
    SearchDependencies.setRepositoryOverride(null);
    ReelsDependencies.setRepositoryOverride(null);
    StoryDependencies.setRepositoryOverride(null);
    ChatDependencies.setRepositoryOverride(null);
  });

  testWidgets('auth role load leads to main tabs', (tester) async {
    final authRepo = MockAuthRepository();
    final profileRepo = MockProfileRepository();
    final requestsRepo = MockRequestsRepository();
    final bookingRepo = MockBookingRepository();
    final searchRepo = MockSearchRepository();
    final reelsRepo = MockReelsRepository();
    final chatRepo = MockChatRepository();

    AuthDependencies.setRepositoryOverride(authRepo);
    ProfileDependencies.setRepositoryOverride(profileRepo);
    RequestsDependencies.setRepositoryOverride(requestsRepo);
    BookingDependencies.setRepositoryOverride(bookingRepo);
    SearchDependencies.setRepositoryOverride(searchRepo);
    ReelsDependencies.setRepositoryOverride(reelsRepo);
    ChatDependencies.setRepositoryOverride(chatRepo);

    when(() => authRepo.getCurrentUser()).thenAnswer(
      (_) async =>
          Result.success(AuthUser(id: 'user1', isAnonymous: false)),
    );
    when(() => profileRepo.getUserProfile(userId: 'user1')).thenAnswer(
      (_) async => Result.success(
        UserProfile(
          id: 'user1',
          role: 'customer',
          name: 'User',
          governorate: 'Baghdad',
          profileCompleted: true,
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
        ),
      ),
    );
    when(() => requestsRepo.getMyRequests(clientId: 'user1')).thenAnswer(
      (_) async => Result.success(<PhotoRequest>[]),
    );
    when(() => bookingRepo.getMyBookings(userId: 'user1')).thenAnswer(
      (_) async => Result.success(<Booking>[]),
    );
    when(() => searchRepo.searchPhotographers(query: any(named: 'query')))
        .thenAnswer(
      (_) async => Result.success(<SearchResultPhotographer>[]),
    );
    when(() => reelsRepo.getReels()).thenAnswer(
      (_) async => Result.success(<ReelModel>[]),
    );
    when(() => chatRepo.getChatThreads(userId: 'user1')).thenAnswer(
      (_) async => Result.success(<ChatThreadPreview>[]),
    );

    await tester.pumpWidget(
      wrapWithMaterial(
        MainAppScreen(
          exploreScreenOverride: ExploreScreen(
            fetchFollowingOverride: (userId) async => const {},
            submitReportOverride: ({
              required reporterId,
              required targetId,
              required targetType,
              required targetOwnerId,
              required reason,
            }) async {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(MainAppScreen), findsOneWidget);
  });

  testWidgets('customer creates request draft and it appears in My Requests',
      (tester) async {
    final authRepo = MockAuthRepository();
    final profileRepo = MockProfileRepository();
    final requestsRepo = InMemoryRequestsRepository();

    AuthDependencies.setRepositoryOverride(authRepo);
    ProfileDependencies.setRepositoryOverride(profileRepo);
    RequestsDependencies.setRepositoryOverride(requestsRepo);

    when(() => authRepo.getCurrentUser()).thenAnswer(
      (_) async =>
          Result.success(AuthUser(id: 'user1', isAnonymous: false)),
    );
    when(() => profileRepo.getUserProfile(userId: 'user1')).thenAnswer(
      (_) async => Result.success(
        UserProfile(
          id: 'user1',
          role: 'customer',
          name: 'User',
          governorate: 'Baghdad',
          profileCompleted: true,
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
        ),
      ),
    );

    String? submittedId;
    await tester.pumpWidget(
      wrapWithMaterial(
        CreateRequestScreen(
          prefillType: 'Wedding',
          prefillStyle: 'Classic',
          prefillGovernorate: 'Baghdad',
          // Keep this far in the future so the test stays valid over time.
          prefillDate: DateTime(2099, 1, 1),
          prefillTime: const TimeOfDay(hour: 10, minute: 0),
          onRequestSubmitted: (id) => submittedId = id,
          locationPicker: (
            context,
            currentPosition,
            currentLabel,
            governorate,
          ) async {
            return LocationSelectionResult(
              position: const LatLng(33.3128, 44.3615),
              label: 'Baghdad',
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    final saveDraftButton = find.widgetWithText(OutlinedButton, 'Save Draft');
    await tester.ensureVisible(saveDraftButton);
    await tester.tap(saveDraftButton);
    await tester.pumpAndSettle();

    expect(submittedId, 'req1');

    await tester.pumpWidget(wrapWithMaterial(const MyRequestsScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Wedding'), findsOneWidget);
  });

  testWidgets('phone auth shows OTP screen after code sent', (tester) async {
    final authRepo = MockAuthRepository();
    AuthDependencies.setRepositoryOverride(authRepo);

    when(
      () => authRepo.verifyPhoneNumber(
        phoneNumber: any(named: 'phoneNumber'),
        onCodeSent: any(named: 'onCodeSent'),
        onVerificationCompleted: any(named: 'onVerificationCompleted'),
        onVerificationFailed: any(named: 'onVerificationFailed'),
        onCodeAutoRetrievalTimeout: any(named: 'onCodeAutoRetrievalTimeout'),
      ),
    ).thenAnswer((invocation) async {
      final onCodeSent =
          invocation.namedArguments[#onCodeSent] as void Function(String, int?);
      onCodeSent('verif123', null);
      return Result.success(null);
    });

    await tester.pumpWidget(wrapWithMaterial(const AuthScreen()));
    await tester.pumpAndSettle();

    final isPhoneAuthSupportedPlatform =
        defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;

    if (!isPhoneAuthSupportedPlatform) {
      // Desktop/web builds intentionally show an info message instead.
      expect(find.textContaining('Android and iOS'), findsOneWidget);
      return;
    }

    await tester.tap(find.textContaining('with Phone'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), '+964 770 000 0000');
    await tester.tap(find.text('Next'));
    await tester.pump();

    expect(find.text('Verify Code'), findsOneWidget);
  });

  testWidgets('photographer creates post with mocked uploader',
      (tester) async {
    final authRepo = MockAuthRepository();
    final profileRepo = MockProfileRepository();
    final reelsRepo = MockReelsRepository();

    AuthDependencies.setRepositoryOverride(authRepo);
    ProfileDependencies.setRepositoryOverride(profileRepo);
    ReelsDependencies.setRepositoryOverride(reelsRepo);

    when(() => authRepo.getCurrentUser()).thenAnswer(
      (_) async =>
          Result.success(AuthUser(id: 'photog1', isAnonymous: false)),
    );
    when(() => profileRepo.getUserProfile(userId: 'photog1')).thenAnswer(
      (_) async => Result.success(
        UserProfile(
          id: 'photog1',
          role: 'photographer',
          name: 'Photographer',
          governorate: 'Baghdad',
          profileCompleted: true,
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
        ),
      ),
    );
    when(
      () => reelsRepo.uploadReelMedia(
        photographerId: any(named: 'photographerId'),
        reelId: any(named: 'reelId'),
        filePath: any(named: 'filePath'),
        contentType: any(named: 'contentType'),
      ),
    ).thenAnswer(
      (_) async => Result.success('https://example.com/thumb.jpg'),
    );
    when(() => reelsRepo.createReel(reel: any(named: 'reel'))).thenAnswer(
      (_) async => Result.success(null),
    );

    Future<XFile?> fakePicker(ImageSource source) async {
      final file = File('${Directory.systemTemp.path}/post.png');
      await file.writeAsBytes(_testPngBytes);
      return XFile(file.path, mimeType: 'image/png');
    }

    await tester.pumpWidget(
      wrapWithMaterial(CreatePostScreen(imagePicker: fakePicker)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('create_post_add_photo_picker')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Gallery'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Publish Post'));
    await tester.pumpAndSettle();

    verify(() => reelsRepo.createReel(reel: any(named: 'reel'))).called(1);
  });

  testWidgets('photographer creates story with mocked uploader',
      (tester) async {
    final authRepo = MockAuthRepository();
    final profileRepo = MockProfileRepository();
    final storyRepo = MockStoryRepository();

    AuthDependencies.setRepositoryOverride(authRepo);
    ProfileDependencies.setRepositoryOverride(profileRepo);
    StoryDependencies.setRepositoryOverride(storyRepo);

    when(() => authRepo.getCurrentUser()).thenAnswer(
      (_) async =>
          Result.success(AuthUser(id: 'photog1', isAnonymous: false)),
    );
    when(() => profileRepo.getUserProfile(userId: 'photog1')).thenAnswer(
      (_) async => Result.success(
        UserProfile(
          id: 'photog1',
          role: 'photographer',
          name: 'Photographer',
          governorate: 'Baghdad',
          profileCompleted: true,
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
        ),
      ),
    );
    when(
      () => storyRepo.uploadStoryImage(
        photographerId: any(named: 'photographerId'),
        storyId: any(named: 'storyId'),
        filePath: any(named: 'filePath'),
        contentType: any(named: 'contentType'),
      ),
    ).thenAnswer(
      (_) async => Result.success('https://example.com/story.jpg'),
    );
    when(() => storyRepo.createStory(story: any(named: 'story'))).thenAnswer(
      (_) async => Result.success(null),
    );

    Future<XFile?> fakePicker(ImageSource source) async {
      final file = File('${Directory.systemTemp.path}/story.png');
      await file.writeAsBytes(_testPngBytes);
      return XFile(file.path, mimeType: 'image/png');
    }

    await tester.pumpWidget(
      wrapWithMaterial(CreateStoryScreen(imagePicker: fakePicker)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('create_story_add_photo_picker')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Gallery'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Share Story'));
    await tester.pumpAndSettle();

    verify(() => storyRepo.createStory(story: any(named: 'story'))).called(1);
  });
}
