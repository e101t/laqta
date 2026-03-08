import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'routes.dart';

// core
import 'package:luqta/core/constants/app_constants.dart';
import 'package:luqta/core/localization/app_localizations.dart';
import 'package:luqta/features/profile/profile_dependencies.dart';

// app shell
import 'package:luqta/app/main_app_screen.dart';

// features (prefer features/* over screens/* shims)
import 'package:luqta/features/auth/presentation/screens/auth_screen.dart';
import 'package:luqta/features/auth/presentation/screens/sign_up_details_screen.dart';
import 'package:luqta/features/onboarding/presentation/screens/splash_screen.dart';
import 'package:luqta/features/onboarding/presentation/screens/language_select_screen.dart';

import 'package:luqta/features/role/presentation/screens/role_picker_screen.dart';
import 'package:luqta/features/profile/presentation/screens/basic_info_screen.dart';
import 'package:luqta/features/profile/presentation/screens/portfolio_editor_screen.dart';
import 'package:luqta/features/profile/presentation/screens/profile_screen.dart';
import 'package:luqta/features/admin/presentation/screens/account_blocked_screen.dart';

import 'package:luqta/features/search/presentation/screens/search_screen.dart';
import 'package:luqta/features/chat/presentation/screens/chat_screen.dart';
import 'package:luqta/features/booking/presentation/screens/booking_details_screen.dart';
import 'package:luqta/features/booking/presentation/screens/my_bookings_screen.dart';
import 'package:luqta/features/payment/presentation/screens/payment_screen.dart';
import 'package:luqta/features/reels/presentation/screens/create_post_screen.dart';
import 'package:luqta/features/requests/presentation/screens/create_request_screen.dart';
import 'package:luqta/features/requests/presentation/screens/my_requests_screen.dart';
import 'package:luqta/features/requests/presentation/screens/offer_submit_screen.dart';
import 'package:luqta/features/requests/presentation/screens/request_details_screen.dart';
import 'package:luqta/features/store/presentation/screens/store_screen.dart';

import 'package:luqta/features/photographer/presentation/screens/photographer_profile_screen.dart';
import 'package:luqta/features/dashboard/presentation/screens/photographer_dashboard_screen.dart';
import 'package:luqta/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:luqta/features/favorites/presentation/screens/favorites_screen.dart';
import 'package:luqta/features/settings/presentation/screens/settings_screen.dart';
import 'package:luqta/features/settings/presentation/screens/policy_terms_screen.dart';
import 'package:luqta/features/settings/presentation/screens/booking_policies_screen.dart';
import 'package:luqta/features/explore/presentation/screens/explore_screen.dart';

import 'package:luqta/features/analytics/presentation/screens/analytics_dashboard_screen.dart';
import 'package:luqta/features/achievements/presentation/screens/achievements_screen.dart';
import 'package:luqta/features/loyalty/presentation/screens/loyalty_points_screen.dart';
import 'package:luqta/features/photographer/presentation/screens/availability_screen.dart';
import 'package:luqta/features/review/presentation/screens/write_review_screen.dart';
import 'package:luqta/features/story/presentation/screens/create_story_screen.dart';

class AppRouter {
  static String? _cachedProfileUserId;
  static bool? _cachedProfileCompleted;
  static String? _cachedProfileRole;
  static bool? _cachedProfileBlocked;
  static bool _splashDelayComplete = false;
  static Future<void>? _splashDelayFuture;
  static FirebaseAuth? _authOverride;

  @visibleForTesting
  static void setAuthOverride(FirebaseAuth? auth) {
    _authOverride = auth;
  }

  @visibleForTesting
  static void setSplashDelayCompleteForTest(bool value) {
    _splashDelayComplete = value;
    if (value) {
      _splashDelayFuture = null;
    }
  }

  static FirebaseAuth get _auth => _authOverride ?? FirebaseAuth.instance;

  static GoRouter createRouter({FirebaseAuth? authOverride}) {
    final auth = authOverride ?? _auth;
    const devStart = String.fromEnvironment('LAQTA_DEV_START', defaultValue: '');
    final devStartPath =
        devStart.isEmpty ? '' : (devStart.startsWith('/') ? devStart : '/$devStart');
    return GoRouter(
      initialLocation: devStartPath.isNotEmpty ? devStartPath : Routes.splash,
      refreshListenable: GoRouterRefreshStream(
        auth.authStateChanges(),
      ),
      redirect: _guardRedirect,
      routes: [
      GoRoute(
        path: Routes.splash,
        name: Routes.nSplash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: Routes.language,
        name: Routes.nLanguage,
        builder: (context, state) => const LanguageSelectScreen(),
      ),
      GoRoute(
        path: Routes.auth,
        name: Routes.nAuth,
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: Routes.signUpDetails,
        name: Routes.nSignUpDetails,
        builder: (context, state) => const SignUpDetailsScreen(),
      ),
      GoRoute(
        path: Routes.blocked,
        name: Routes.nBlocked,
        builder: (context, state) => const AccountBlockedScreen(),
      ),

      // profile completion flow
      GoRoute(
        path: Routes.role,
        name: Routes.nRole,
        builder: (context, state) => const RolePickerScreen(),
      ),
      GoRoute(
        path: Routes.basicInfo,
        name: Routes.nBasicInfo,
        builder: (context, state) {
          final role = (state.uri.queryParameters['role'] ?? '').trim();
          final normalizedRole =
              (role == AppConstants.roleCustomer ||
                      role == AppConstants.rolePhotographer ||
                      role == AppConstants.roleAdmin)
                  ? role
                  : '';
          return BasicInfoScreen(userRole: normalizedRole);
        },
      ),
      GoRoute(
        path: Routes.portfolioEditor,
        name: Routes.nPortfolioEditor,
        builder: (context, state) => const PortfolioEditorScreen(),
      ),

      // shell
      GoRoute(
        path: Routes.main,
        name: Routes.nMain,
        builder: (context, state) => const MainAppScreen(),
      ),

      // core routes
      GoRoute(
        path: Routes.bookings,
        name: Routes.nBookings,
        builder: (context, state) => const MyBookingsScreen(),
      ),
      GoRoute(
        path: Routes.booking,
        name: Routes.nBooking,
        builder: (context, state) {
          final bookingId = state.pathParameters['id'];
          if (bookingId == null || bookingId.isEmpty) {
            return const Scaffold(
              body: Center(child: Text('Missing booking id')),
            );
          }
          return BookingDetailsScreen(bookingId: bookingId);
        },
      ),
      GoRoute(
        path: Routes.requests,
        name: Routes.nRequests,
        builder: (context, state) => const MyRequestsScreen(),
      ),
      GoRoute(
        path: Routes.shop,
        name: Routes.nShop,
        builder: (context, state) => const StoreScreen(),
      ),
      GoRoute(
        path: Routes.requestCreate,
        name: Routes.nRequestCreate,
        builder: (context, state) => const CreateRequestScreen(),
      ),
      GoRoute(
        path: Routes.requestDetails,
        name: Routes.nRequestDetails,
        builder: (context, state) {
          final requestId = state.pathParameters['id'];
          if (requestId == null || requestId.isEmpty) {
            return const Scaffold(
              body: Center(child: Text('Missing request id')),
            );
          }
          return RequestDetailsScreen(requestId: requestId);
        },
      ),
      GoRoute(
        path: Routes.offerSubmit,
        name: Routes.nOfferSubmit,
        builder: (context, state) {
          final requestId = state.pathParameters['id'];
          if (requestId == null || requestId.isEmpty) {
            return const Scaffold(
              body: Center(child: Text('Missing request id')),
            );
          }
          return OfferSubmitScreen(requestId: requestId);
        },
      ),
      GoRoute(
        path: Routes.chat,
        name: Routes.nChat,
        builder: (context, state) {
          final chatId = state.pathParameters['id'];
          if (chatId == null || chatId.isEmpty) {
            return const Scaffold(body: Center(child: Text('Missing chat id')));
          }
          final otherUserName = state.uri.queryParameters['name'] ?? 'Unknown';
          return ChatScreen(chatId: chatId, otherUserName: otherUserName);
        },
      ),
      GoRoute(
        path: Routes.photographer,
        name: Routes.nPhotographer,
        builder: (context, state) {
          final photographerId = state.pathParameters['id'];
          if (photographerId == null || photographerId.isEmpty) {
            return const Scaffold(
              body: Center(child: Text('Missing photographer id')),
            );
          }
          return PhotographerProfileScreen(photographerId: photographerId);
        },
      ),

      // misc
      GoRoute(
        path: Routes.search,
        name: Routes.nSearch,
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: Routes.explore,
        name: Routes.nExplore,
        builder: (context, state) => const ExploreScreen(),
      ),
      GoRoute(
        path: Routes.profile,
        name: Routes.nProfile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: Routes.dashboard,
        name: Routes.nDashboard,
        builder: (context, state) => const PhotographerDashboardScreen(),
      ),
      GoRoute(
        path: Routes.notifications,
        name: Routes.nNotifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: Routes.favorites,
        name: Routes.nFavorites,
        builder: (context, state) => const FavoritesScreen(),
      ),
      GoRoute(
        path: Routes.settings,
        name: Routes.nSettings,
        builder: (context, state) => const SettingsScreen(),
      ),

      // legal
      GoRoute(
        path: Routes.policy,
        name: Routes.nPolicy,
        builder: (context, state) =>
            const PolicyTermsScreen(type: PolicyType.privacy),
      ),
      GoRoute(
        path: Routes.terms,
        name: Routes.nTerms,
        builder: (context, state) =>
            const PolicyTermsScreen(type: PolicyType.terms),
      ),
      GoRoute(
        path: Routes.bookingPolicies,
        name: Routes.nBookingPolicies,
        builder: (context, state) => const BookingPoliciesScreen(),
      ),

      // extras
      GoRoute(
        path: Routes.loyalty,
        name: Routes.nLoyalty,
        builder: (context, state) => const LoyaltyPointsScreen(),
      ),
      GoRoute(
        path: Routes.analytics,
        name: Routes.nAnalytics,
        builder: (context, state) => const AnalyticsDashboardScreen(),
      ),
      GoRoute(
        path: Routes.achievements,
        name: Routes.nAchievements,
        builder: (context, state) => const AchievementsScreen(),
      ),
      GoRoute(
        path: Routes.availability,
        name: Routes.nAvailability,
        builder: (context, state) => const AvailabilityScreen(),
      ),
      GoRoute(
        path: Routes.payment,
        name: Routes.nPayment,
        builder: (context, state) {
          final bookingId = state.uri.queryParameters['bookingId'];
          final amount = double.tryParse(
            state.uri.queryParameters['amount'] ?? '',
          );
          final photographerName =
              state.uri.queryParameters['photographerName'] ?? '';
          final sessionType = state.uri.queryParameters['sessionType'] ?? '';

          if (bookingId == null || amount == null) {
            return const Scaffold(
              body: Center(child: Text('Missing payment information')),
            );
          }

          return PaymentScreen(
            bookingId: bookingId,
            amount: amount,
            photographerName: photographerName,
            sessionType: sessionType,
          );
        },
      ),
      GoRoute(
        path: Routes.writeReview,
        name: Routes.nWriteReview,
        builder: (context, state) {
          final bookingId = state.uri.queryParameters['bookingId'];
          final photographerId = state.uri.queryParameters['photographerId'];
          final photographerName =
              state.uri.queryParameters['photographerName'];

          if (bookingId == null ||
              photographerId == null ||
              photographerName == null) {
            final localizations = AppLocalizations.of(context);
            return Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    localizations.missingReviewInfo,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          }

          return WriteReviewScreen(
            bookingId: bookingId,
            photographerId: photographerId,
            photographerName: photographerName,
          );
        },
      ),
      GoRoute(
        path: Routes.createPost,
        name: Routes.nCreatePost,
        builder: (context, state) => const CreatePostScreen(),
      ),
      GoRoute(
        path: Routes.createStory,
        name: Routes.nCreateStory,
        builder: (context, state) => const CreateStoryScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.uri.path}')),
    ),
    );
  }

  static final GoRouter router = createRouter();

  static Future<String?> _guardRedirect(
    BuildContext context,
    GoRouterState state,
  ) async {
    final path = state.uri.path;
    const devStart = String.fromEnvironment('LAQTA_DEV_START', defaultValue: '');
    final devStartPath =
        devStart.isEmpty ? '' : (devStart.startsWith('/') ? devStart : '/$devStart');
    const devLock = bool.fromEnvironment('LAQTA_DEV_LOCK', defaultValue: false);
    const devBypassAuth =
        bool.fromEnvironment('LAQTA_DEV_BYPASS_AUTH', defaultValue: false);
    if (kDebugMode && devLock && devStartPath.isNotEmpty) {
      return path == devStartPath ? null : devStartPath;
    }

    final isSplash = path == Routes.splash;
    final isLanguage = path == Routes.language;
    final isAuth = path == Routes.auth;
    final isSignUpDetails = path == Routes.signUpDetails;
    final isRole = path == Routes.role;
    final isBasicInfo = path == Routes.basicInfo;
    final isBlockedRoute = path == Routes.blocked;

    if (isSplash && !_splashDelayComplete) {
      _splashDelayFuture ??= Future.delayed(
        const Duration(milliseconds: AppConstants.splashDuration),
      );
      await _splashDelayFuture;
      _splashDelayComplete = true;
    }

    final prefs = await SharedPreferences.getInstance();
    final languageSelected = prefs.containsKey(AppConstants.keyLanguage);
    final shouldBypassLanguage =
        kDebugMode && devStartPath.isNotEmpty; // dev-only: allow deep-linking screens
    if (!languageSelected && !isLanguage && !shouldBypassLanguage) {
      return Routes.language;
    }
    if (isLanguage) {
      return null;
    }
    final user = _auth.currentUser;
    if (user == null) {
      _cachedProfileUserId = null;
      _cachedProfileCompleted = null;

      if (kDebugMode && devBypassAuth) {
        if (isSplash) return devStartPath.isNotEmpty ? devStartPath : Routes.main;
        return null;
      }

      if (isSplash) return Routes.auth;
      if (isAuth || isSignUpDetails) return null;
      return Routes.auth;
    }

    final profileStatus = await _getProfileStatus(user.uid);
    final profileCompleted = profileStatus.completed;
    final role = profileStatus.role.trim();
    final hasRole = role.isNotEmpty;
    final inProfileFlow = isRole || isBasicInfo;
    final isBlocked = profileStatus.isBlocked;

    if (isBlocked && !isBlockedRoute) {
      return Routes.blocked;
    }
    if (!isBlocked && isBlockedRoute) {
      if (profileCompleted) return Routes.main;
      if (!hasRole) return Routes.role;
      final query = Uri(queryParameters: {'role': role}).query;
      return '${Routes.basicInfo}?$query';
    }

    if (isSplash) {
      if (profileCompleted) return Routes.main;
      if (!hasRole) return Routes.basicInfo;
      final query = Uri(queryParameters: {'role': role}).query;
      return '${Routes.basicInfo}?$query';
    }

    if (!profileCompleted) {
      if (!isBasicInfo) {
        if (hasRole) {
          final query = Uri(queryParameters: {'role': role}).query;
          return '${Routes.basicInfo}?$query';
        }
        return Routes.basicInfo;
      }
    }

    if (profileCompleted && (isAuth || isSignUpDetails || inProfileFlow)) {
      return Routes.main;
    }

    return null;
  }

  static Future<_ProfileStatus> _getProfileStatus(String userId) async {
    if (_cachedProfileUserId == userId && _cachedProfileCompleted != null) {
      return _ProfileStatus(
        completed: _cachedProfileCompleted ?? false,
        role: _cachedProfileRole ?? '',
        isBlocked: _cachedProfileBlocked ?? false,
      );
    }

    final result = await ProfileDependencies.getUserProfile().call(
      userId: userId,
    );
    if (!result.isSuccess) {
      _cachedProfileUserId = userId;
      _cachedProfileCompleted = false;
      _cachedProfileRole = '';
      _cachedProfileBlocked = false;
      return const _ProfileStatus(
        completed: false,
        role: '',
        isBlocked: false,
      );
    }

    final user = result.valueOrNull;
    final completed = user?.profileCompleted ?? false;
    final role = user?.role ?? '';
    final isBlocked =
        user?.blockedUsers.contains(AppConstants.adminBlockMarker) ?? false;
    _cachedProfileUserId = userId;
    _cachedProfileCompleted = completed;
    _cachedProfileRole = role;
    _cachedProfileBlocked = isBlocked;
    return _ProfileStatus(
      completed: completed,
      role: role,
      isBlocked: isBlocked,
    );
  }

  static void invalidateProfileCache([String? userId]) {
    if (userId == null || userId == _cachedProfileUserId) {
      _cachedProfileUserId = null;
      _cachedProfileCompleted = null;
      _cachedProfileRole = null;
      _cachedProfileBlocked = null;
    }
  }

  // Backward-compatible aliases (some screens may call AppRouter.settings etc.)
  static const String settings = Routes.settings;
  static const String availability = Routes.availability;
  static const String analytics = Routes.analytics;

  // Navigation helpers
  static void goToHome(BuildContext context) => context.go(Routes.main);
  static void goToLanguage(BuildContext context) => context.go(Routes.language);
  static void goToAuth(BuildContext context) => context.go(Routes.auth);
  static void goToSignUpDetails(BuildContext context) =>
      context.go(Routes.signUpDetails);
  static void goToRole(BuildContext context) => context.go(Routes.role);
  static void goToProfileSetup(BuildContext context) =>
      context.go(Routes.basicInfo);

  static void goToBookings(BuildContext context) => context.go(Routes.bookings);
  static void goToMyRequests(BuildContext context) =>
      context.go(Routes.requests);
  static void goToShop(BuildContext context) => context.go(Routes.shop);
  static void goToCreateRequest(BuildContext context) =>
      context.go(Routes.requestCreate);
  static void goToExplore(BuildContext context) => context.go(Routes.explore);
  static void goToPolicy(BuildContext context) => context.go(Routes.policy);
  static void goToTerms(BuildContext context) => context.go(Routes.terms);
  static void goToBookingPolicies(BuildContext context) =>
      context.go(Routes.bookingPolicies);
  static void goToProfile(BuildContext context) => context.go(Routes.profile);

  static void goToBasicInfo(BuildContext context, String role) {
    assert(role.isNotEmpty, 'role is required');
    final query = Uri(queryParameters: {'role': role}).query;
    context.go('${Routes.basicInfo}?$query');
  }

  static void goToPortfolioEditor(BuildContext context) =>
      context.go(Routes.portfolioEditor);

  static void goToSettings(BuildContext context) => context.go(Routes.settings);

  static void goToChat(
    BuildContext context,
    String chatId,
    String otherUserName,
  ) {
    assert(chatId.isNotEmpty, 'chatId is required');
    final path = _resolvePath(Routes.chat, {'id': chatId});
    final encodedName = Uri.encodeComponent(otherUserName);
    context.go('$path?name=$encodedName');
  }

  static void goToBookingDetails(BuildContext context, String bookingId) {
    assert(bookingId.isNotEmpty, 'bookingId is required');
    context.go(_resolvePath(Routes.booking, {'id': bookingId}));
  }

  static void goToRequestDetails(BuildContext context, String requestId) {
    assert(requestId.isNotEmpty, 'requestId is required');
    context.go(_resolvePath(Routes.requestDetails, {'id': requestId}));
  }

  static void goToOfferSubmit(BuildContext context, String requestId) {
    assert(requestId.isNotEmpty, 'requestId is required');
    context.go(_resolvePath(Routes.offerSubmit, {'id': requestId}));
  }

  static void goToPhotographerProfile(
    BuildContext context,
    String photographerId,
  ) {
    assert(photographerId.isNotEmpty, 'photographerId is required');
    context.go(_resolvePath(Routes.photographer, {'id': photographerId}));
  }

  static void goToFavorites(BuildContext context) =>
      context.go(Routes.favorites);
  static void goToNotifications(BuildContext context) =>
      context.go(Routes.notifications);
  static void goToDashboard(BuildContext context) =>
      context.go(Routes.dashboard);
  static void goToSearch(BuildContext context) => context.go(Routes.search);
  static void goToLoyaltyPoints(BuildContext context) =>
      context.go(Routes.loyalty);
  static void goToAchievements(BuildContext context) =>
      context.go(Routes.achievements);
  static void goToAvailability(BuildContext context) =>
      context.go(Routes.availability);

  static void goToWriteReview(
    BuildContext context,
    String bookingId,
    String photographerId,
    String photographerName,
  ) {
    assert(bookingId.isNotEmpty, 'bookingId is required');
    assert(photographerId.isNotEmpty, 'photographerId is required');
    assert(photographerName.isNotEmpty, 'photographerName is required');
    final query = Uri(
      queryParameters: {
        'bookingId': bookingId,
        'photographerId': photographerId,
        'photographerName': photographerName,
      },
    ).query;
    context.go('${Routes.writeReview}?$query');
  }

  static void goToPayment(
    BuildContext context,
    String bookingId,
    double amount,
    String photographerName,
    String sessionType,
  ) {
    assert(bookingId.isNotEmpty, 'bookingId is required');
    assert(amount.isFinite, 'amount must be finite');
    final query = Uri(
      queryParameters: {
        'bookingId': bookingId,
        'amount': amount.toString(),
        'photographerName': photographerName,
        'sessionType': sessionType,
      },
    ).query;
    context.go('${Routes.payment}?$query');
  }

  static void goToCreatePost(BuildContext context) =>
      context.go(Routes.createPost);

  static void goToCreateStory(BuildContext context) =>
      context.go(Routes.createStory);

  static String _resolvePath(String template, Map<String, String> params) {
    var resolved = template;
    params.forEach((key, value) {
      resolved = resolved.replaceFirst(':$key', Uri.encodeComponent(value));
    });
    return resolved;
  }
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class _ProfileStatus {
  final bool completed;
  final String role;
  final bool isBlocked;

  const _ProfileStatus({
    required this.completed,
    required this.role,
    required this.isBlocked,
  });
}
