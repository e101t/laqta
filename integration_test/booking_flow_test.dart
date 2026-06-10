import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:laqta/app/router/routes.dart';
import 'package:laqta/core/domain/result/result.dart';
import 'package:laqta/core/domain/failures/failure.dart';
import 'package:laqta/core/localization/app_localizations.dart';
import 'package:laqta/core/widgets/app_buttons.dart';
import 'package:laqta/features/auth/auth_dependencies.dart';
import 'package:laqta/features/auth/domain/entities/auth_user.dart';
import 'package:laqta/features/booking/booking_dependencies.dart';
import 'package:laqta/features/booking/domain/entities/booking.dart';
import 'package:laqta/features/booking/domain/repositories/booking_repository.dart';
import 'package:laqta/features/booking/presentation/mappers/booking_presentation_mapper.dart';
import 'package:laqta/features/booking/presentation/screens/booking_details_screen.dart';
import 'package:laqta/features/notifications/notifications_dependencies.dart';
import 'package:laqta/features/profile/domain/entities/user_profile.dart';
import 'package:laqta/features/profile/profile_dependencies.dart';
import 'package:laqta/features/requests/domain/entities/photo_request.dart';
import 'package:laqta/features/requests/domain/entities/request_deliverables.dart';
import 'package:laqta/features/requests/domain/entities/request_offer.dart';
import 'package:laqta/features/requests/domain/repositories/requests_repository.dart';
import 'package:laqta/features/requests/requests_dependencies.dart';
import 'package:laqta/features/requests/presentation/screens/my_requests_screen.dart';
import 'package:laqta/features/requests/presentation/screens/offer_submit_screen.dart';
import 'package:laqta/features/requests/presentation/screens/photographer_requests_screen.dart';
import 'package:laqta/features/requests/presentation/screens/request_details_screen.dart';
import 'package:laqta/features/trust/domain/entities/trust_stats.dart';
import 'package:laqta/features/trust/domain/repositories/trust_repository.dart';
import 'package:laqta/features/trust/trust_dependencies.dart';
import '../test/helpers/mocks.dart';

class InMemoryRequestsRepository implements RequestsRepository {
  final Map<String, PhotoRequest> _requests = {};
  final Map<String, List<RequestOffer>> _offers = {};
  Booking? lastAcceptedBooking;
  int _offerCounter = 1;
  int _requestCounter = 1;

  void seedRequests(List<PhotoRequest> requests) {
    for (final request in requests) {
      _requests[request.id] = request;
    }
  }

  void seedOffers(String requestId, List<RequestOffer> offers) {
    _offers[requestId] = List<RequestOffer>.from(offers);
  }

  @override
  Future<Result<List<PhotoRequest>>> getMyRequests({
    required String clientId,
  }) async {
    final items =
        _requests.values.where((r) => r.clientId == clientId).toList();
    return Result.success(items);
  }

  @override
  Future<Result<List<PhotoRequest>>> getOpenRequests({
    String? governorate,
  }) async {
    final items = _requests.values
        .where((r) => r.status != 'closed' && r.status != 'canceled')
        .where(
          (r) => governorate == null || r.governorate == governorate,
        )
        .toList();
    return Result.success(items);
  }

  @override
  Future<Result<PhotoRequest>> getRequestById(String requestId) async {
    final request = _requests[requestId];
    if (request == null) {
      return Result.failure(const Failure(message: 'Not found'));
    }
    return Result.success(request);
  }

  @override
  Future<Result<void>> createRequest(PhotoRequest request) async {
    _requests[request.id] = request;
    return Result.success(null);
  }

  @override
  Future<Result<void>> updateRequest({
    required String requestId,
    required Map<String, dynamic> updates,
  }) async {
    final request = _requests[requestId];
    if (request == null) {
      return Result.failure(const Failure(message: 'Not found'));
    }
    final status = updates['status'] as String?;
    _requests[requestId] = request.copyWith(
      status: status ?? request.status,
      updatedAt: DateTime.now(),
    );
    return Result.success(null);
  }

  @override
  Future<Result<List<RequestOffer>>> getOffersForRequest(
    String requestId,
  ) async {
    return Result.success(_offers[requestId] ?? <RequestOffer>[]);
  }

  @override
  Future<Result<List<RequestOffer>>> getMyOffers({
    required String photographerId,
  }) async {
    final items = _offers.values
        .expand((list) => list)
        .where((offer) => offer.photographerId == photographerId)
        .toList();
    return Result.success(items);
  }

  @override
  Future<Result<void>> createOffer(RequestOffer offer) async {
    final list = _offers.putIfAbsent(offer.requestId, () => <RequestOffer>[]);
    list.add(offer);
    final request = _requests[offer.requestId];
    if (request != null) {
      _requests[offer.requestId] = request.copyWith(
        offersCount: list.length,
        updatedAt: DateTime.now(),
      );
    }
    return Result.success(null);
  }

  @override
  Future<Result<void>> acceptOffer({
    required PhotoRequest request,
    required RequestOffer offer,
    required Booking booking,
  }) async {
    lastAcceptedBooking = booking;
    _requests[request.id] = request.copyWith(
      status: 'offer_selected',
      selectedOfferId: offer.id,
      selectedPhotographerId: offer.photographerId,
      updatedAt: DateTime.now(),
    );
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
  String generateRequestId() => 'req${_requestCounter++}';

  @override
  String generateOfferId() => 'offer${_offerCounter++}';
}

class InMemoryBookingRepository implements BookingRepository {
  final Map<String, Booking> _bookings = {};
  int _bookingCounter = 1;

  @override
  Future<Result<List<Booking>>> getMyBookings({required String userId}) async {
    final items = _bookings.values
        .where(
          (booking) =>
              booking.customerId == userId ||
              booking.photographerId == userId,
        )
        .toList();
    return Result.success(items);
  }

  @override
  Future<Result<Booking>> getBookingById(String bookingId) async {
    final booking = _bookings[bookingId];
    if (booking == null) {
      return Result.failure(const Failure(message: 'Not found'));
    }
    return Result.success(booking);
  }

  @override
  Future<Result<void>> createBooking(Booking booking) async {
    _bookings[booking.id] = booking;
    return Result.success(null);
  }

  @override
  Future<Result<void>> updateBookingStatus({
    required String bookingId,
    required String status,
  }) async {
    final booking = _bookings[bookingId];
    if (booking == null) {
      return Result.failure(const Failure(message: 'Not found'));
    }
    _bookings[bookingId] = Booking(
      id: booking.id,
      customerId: booking.customerId,
      photographerId: booking.photographerId,
      requestId: booking.requestId,
      offerId: booking.offerId,
      date: booking.date,
      time: booking.time,
      duration: booking.duration,
      type: booking.type,
      price: booking.price,
      currency: booking.currency,
      status: status,
      payment: booking.payment,
      location: booking.location,
      deliverables: booking.deliverables,
      notes: booking.notes,
      chatId: booking.chatId,
      deliveryId: booking.deliveryId,
      disputeId: booking.disputeId,
      revisionCount: booking.revisionCount,
      canceledBy: booking.canceledBy,
      timeline: booking.timeline,
      createdAt: booking.createdAt,
      updatedAt: DateTime.now(),
    );
    return Result.success(null);
  }

  @override
  Future<Result<void>> updateBooking({
    required String bookingId,
    required Map<String, dynamic> updates,
  }) async {
    if (!_bookings.containsKey(bookingId)) {
      return Result.failure(const Failure(message: 'Not found'));
    }
    return Result.success(null);
  }

  @override
  String generateBookingId() => 'booking${_bookingCounter++}';
}

class FakeTrustRepository implements TrustRepository {
  @override
  Future<Result<TrustStats?>> getTrustStats(String photographerId) async {
    return Result.success(
      TrustStats(
        photographerId: photographerId,
        reviewCount: 4,
        sumQuality: 18,
        sumCommunication: 17,
        sumOnTime: 16,
        sumDelivery: 19,
        completedBookings: 12,
        canceledByPhotographer: 1,
        disputesCount: 0,
        updatedAt: DateTime(2026, 1, 1),
      ),
    );
  }

  @override
  Future<Result<void>> incrementReviewStats({
    required String bookingId,
    required String photographerId,
    required double qualityRating,
    required double communicationRating,
    required double onTimeRating,
    required double deliverySpeedRating,
  }) async {
    return Result.success(null);
  }

  @override
  Future<Result<void>> incrementCompletedBookings({
    required String bookingId,
    required String photographerId,
  }) async {
    return Result.success(null);
  }

  @override
  Future<Result<void>> incrementCanceledByPhotographer({
    required String bookingId,
    required String photographerId,
  }) async {
    return Result.success(null);
  }

  @override
  Future<Result<void>> incrementDisputesCount({
    required String bookingId,
    required String photographerId,
  }) async {
    return Result.success(null);
  }
}

Widget wrapWithRouter(GoRouter router) {
  return MaterialApp.router(
    routerConfig: router,
    locale: const Locale('en'),
    supportedLocales: const [Locale('en')],
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
  );
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  registerFallbacks();

  tearDown(() {
    AuthDependencies.setRepositoryOverride(null);
    ProfileDependencies.setRepositoryOverride(null);
    RequestsDependencies.setRepositoryOverride(null);
    BookingDependencies.setRepositoryOverride(null);
    NotificationsDependencies.setRepositoryOverride(null);
    TrustDependencies.setRepositoryOverride(null);
  });

  testWidgets('customer accepts offer then booking details shows status',
      (tester) async {
    final authRepo = MockAuthRepository();
    final profileRepo = MockProfileRepository();
    final notificationsRepo = MockNotificationsRepository();
    final requestsRepo = InMemoryRequestsRepository();
    final bookingRepo = InMemoryBookingRepository();
    final trustRepo = FakeTrustRepository();

    AuthDependencies.setRepositoryOverride(authRepo);
    ProfileDependencies.setRepositoryOverride(profileRepo);
    RequestsDependencies.setRepositoryOverride(requestsRepo);
    BookingDependencies.setRepositoryOverride(bookingRepo);
    NotificationsDependencies.setRepositoryOverride(notificationsRepo);
    TrustDependencies.setRepositoryOverride(trustRepo);

    when(() => authRepo.getCurrentUser()).thenAnswer(
      (_) async =>
          Result.success(AuthUser(id: 'cust1', isAnonymous: false)),
    );
    when(() => profileRepo.getUserProfile(userId: 'photog1')).thenAnswer(
      (_) async => Result.success(
        UserProfile(
          id: 'photog1',
          role: 'photographer',
          name: 'Photographer One',
          governorate: 'Baghdad',
          profileCompleted: true,
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
        ),
      ),
    );
    when(() => notificationsRepo.createNotification(any()))
        .thenAnswer((_) async => Result.success(null));

    final request = PhotoRequest(
      id: 'req1',
      clientId: 'cust1',
      type: 'Wedding',
      date: '2026-02-01',
      time: '10:00',
      governorate: 'Baghdad',
      durationHours: 2,
      deliverables: const RequestDeliverables(),
      referenceImages: const [],
      status: 'open',
      offersCount: 1,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );
    final offer = RequestOffer(
      id: 'offer1',
      requestId: request.id,
      photographerId: 'photog1',
      price: 200,
      currency: 'IQD',
      deliveryDays: 4,
      deliverables: const RequestDeliverables(),
      status: 'submitted',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );
    requestsRepo.seedRequests([request]);
    requestsRepo.seedOffers(request.id, [offer]);

    final router = GoRouter(
      initialLocation: Routes.requests,
      routes: [
        GoRoute(
          path: Routes.requests,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: MyRequestsScreen(),
          ),
        ),
        GoRoute(
          path: Routes.requestDetails,
          pageBuilder: (context, state) {
            final requestId = state.pathParameters['id']!;
            return NoTransitionPage(
              child: RequestDetailsScreen(requestId: requestId),
            );
          },
        ),
        GoRoute(
          path: Routes.booking,
          pageBuilder: (context, state) {
            final bookingId = state.pathParameters['id']!;
            final booking = requestsRepo.lastAcceptedBooking;
            return NoTransitionPage(
              child: BookingDetailsScreen(
                bookingId: bookingId,
                initialBooking: booking != null
                    ? BookingPresentationMapper.toModel(booking)
                    : null,
                currentUserIdOverride: 'cust1',
                loadOnInit: booking == null,
              ),
            );
          },
        ),
      ],
    );

    await tester.pumpWidget(wrapWithRouter(router));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Active'));
    await tester.pumpAndSettle();

    expect(find.text('Wedding'), findsOneWidget);
    await tester.tap(find.text('Wedding'));
    await tester.pumpAndSettle();

    final acceptButton = find.text('Accept Offer');
    await tester.ensureVisible(acceptButton);
    await tester.tap(acceptButton);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Accept'));
    await tester.pumpAndSettle();

    expect(requestsRepo.lastAcceptedBooking?.status, 'pending');
    expect(find.byType(BookingDetailsScreen), findsOneWidget);
  });

  testWidgets('photographer submits offer from open requests',
      (tester) async {
    final authRepo = MockAuthRepository();
    final profileRepo = MockProfileRepository();
    final notificationsRepo = MockNotificationsRepository();
    final requestsRepo = InMemoryRequestsRepository();

    AuthDependencies.setRepositoryOverride(authRepo);
    ProfileDependencies.setRepositoryOverride(profileRepo);
    RequestsDependencies.setRepositoryOverride(requestsRepo);
    NotificationsDependencies.setRepositoryOverride(notificationsRepo);

    when(() => authRepo.getCurrentUser()).thenAnswer(
      (_) async =>
          Result.success(AuthUser(id: 'photog1', isAnonymous: false)),
    );
    when(() => profileRepo.getUserProfile(userId: 'photog1')).thenAnswer(
      (_) async => Result.success(
        UserProfile(
          id: 'photog1',
          role: 'photographer',
          name: 'Photographer One',
          governorate: 'Baghdad',
          profileCompleted: true,
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
        ),
      ),
    );
    when(() => notificationsRepo.createNotification(any()))
        .thenAnswer((_) async => Result.success(null));

    final request = PhotoRequest(
      id: 'req2',
      clientId: 'cust2',
      type: 'Engagement',
      date: '2026-03-01',
      time: '18:00',
      governorate: 'Baghdad',
      durationHours: 3,
      deliverables: const RequestDeliverables(),
      referenceImages: const [],
      status: 'open',
      offersCount: 0,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );
    requestsRepo.seedRequests([request]);

    final router = GoRouter(
      initialLocation: '/open-requests',
      routes: [
        GoRoute(
          path: '/open-requests',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: PhotographerRequestsScreen(),
          ),
        ),
        GoRoute(
          path: Routes.requestDetails,
          pageBuilder: (context, state) {
            final requestId = state.pathParameters['id']!;
            return NoTransitionPage(
              child: RequestDetailsScreen(requestId: requestId),
            );
          },
        ),
        GoRoute(
          path: Routes.offerSubmit,
          pageBuilder: (context, state) {
            final requestId = state.pathParameters['id']!;
            return NoTransitionPage(
              child: OfferSubmitScreen(
                requestId: requestId,
                onOfferSubmitted: () async {},
              ),
            );
          },
        ),
      ],
    );

    await tester.pumpWidget(wrapWithRouter(router));
    await tester.pumpAndSettle();

    expect(find.text('Engagement'), findsOneWidget);
    await tester.tap(find.text('Engagement'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), '250');
    await tester.enterText(fields.at(1), '3');
    await tester.pump();

    await tester.tap(find.widgetWithText(CTAButton, 'Send Offer'));
    await tester.pumpAndSettle();

    final offers = await requestsRepo.getOffersForRequest(request.id);
    expect(offers.valueOrNull?.length ?? 0, 1);
  });
}
