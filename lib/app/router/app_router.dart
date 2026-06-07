import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'routes.dart';

// core
import 'package:laqta/core/constants/app_constants.dart';
import 'package:laqta/core/localization/app_localizations.dart';
import 'package:laqta/core/services/backend_session_service.dart';
import 'package:laqta/features/profile/profile_dependencies.dart';

// app shell
import 'package:laqta/app/main_app_screen.dart';

// features (prefer features/* over screens/* shims)
import 'package:laqta/features/auth/presentation/screens/auth_screen.dart';
import 'package:laqta/features/auth/presentation/screens/sign_up_details_screen.dart';
import 'package:laqta/features/onboarding/presentation/screens/splash_screen.dart';
import 'package:laqta/features/onboarding/presentation/screens/language_select_screen.dart';

import 'package:laqta/features/role/presentation/screens/role_picker_screen.dart';
import 'package:laqta/features/profile/presentation/screens/basic_info_screen.dart';
import 'package:laqta/features/profile/presentation/screens/portfolio_editor_screen.dart';
import 'package:laqta/features/profile/presentation/screens/profile_screen.dart';
import 'package:laqta/features/admin/presentation/screens/account_blocked_screen.dart';

import 'package:laqta/features/search/presentation/screens/search_screen.dart';
import 'package:laqta/features/chat/presentation/screens/chat_screen.dart';
import 'package:laqta/features/booking/presentation/screens/booking_details_screen.dart';
import 'package:laqta/features/booking/presentation/screens/my_bookings_screen.dart';
import 'package:laqta/features/payment/presentation/screens/payment_screen.dart';
import 'package:laqta/features/reels/presentation/screens/create_post_screen.dart';
import 'package:laqta/features/requests/presentation/screens/create_request_screen.dart';
import 'package:laqta/features/requests/presentation/screens/my_requests_screen.dart';
import 'package:laqta/features/requests/presentation/screens/offer_submit_screen.dart';
import 'package:laqta/features/requests/presentation/screens/request_details_screen.dart';
import 'package:laqta/features/store/presentation/screens/store_screen.dart';

import 'package:laqta/features/photographer/presentation/screens/photographer_profile_screen.dart';
import 'package:laqta/features/dashboard/presentation/screens/photographer_dashboard_screen.dart';
import 'package:laqta/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:laqta/features/favorites/presentation/screens/favorites_screen.dart';
import 'package:laqta/features/settings/presentation/screens/settings_screen.dart';
import 'package:laqta/features/settings/presentation/screens/policy_terms_screen.dart';
import 'package:laqta/features/settings/presentation/screens/booking_policies_screen.dart';
import 'package:laqta/features/explore/presentation/screens/explore_screen.dart';
import 'package:laqta/features/venues/presentation/screens/venues_list_screen.dart';
import 'package:laqta/features/venues/presentation/screens/venue_details_screen.dart';
import 'package:laqta/features/venues/presentation/screens/venue_booking_screen.dart';
import 'package:laqta/features/locations/presentation/screens/photo_location_details_screen.dart';
import 'package:laqta/features/monetization/presentation/screens/subscription_plans_screen.dart';
import 'package:laqta/features/monetization/presentation/screens/sponsored_ad_screen.dart';
import 'package:laqta/features/monetization/presentation/screens/campaign_analytics_screen.dart';
import 'package:laqta/features/verification/presentation/screens/photographer_verification_screen.dart';

import 'package:laqta/features/analytics/presentation/screens/analytics_dashboard_screen.dart';
import 'package:laqta/features/achievements/presentation/screens/achievements_screen.dart';
import 'package:laqta/features/loyalty/presentation/screens/loyalty_points_screen.dart';
import 'package:laqta/features/photographer/presentation/screens/availability_screen.dart';
import 'package:laqta/features/review/presentation/screens/write_review_screen.dart';
import 'package:laqta/features/story/presentation/screens/create_story_screen.dart';

class AppRouter {
  static const Duration _profileStatusTimeout = Duration(seconds: 6);
  static String? _cachedProfileUserId;
  static bool? _cachedProfileCompleted;
  static String? _cachedProfileRole;
  static bool? _cachedProfileBlocked;
  static bool _splashDelayComplete = false;
  static Future<void>? _splashDelayFuture;
  static BackendSessionService _sessionService = BackendSessionService();

  @visibleForTesting
  static void setSessionServiceOverride(BackendSessionService? sessionService) {
    _sessionService = sessionService ?? BackendSessionService();
  }

  @visibleForTesting
  static void setSplashDelayCompleteForTest(bool value) {
    _splashDelayComplete = value;
    if (value) {
      _splashDelayFuture = null;
    }
  }

  static GoRouter createRouter({BackendSessionService? sessionOverride}) {
    if (sessionOverride != null) {
      _sessionService = sessionOverride;
    }
    const devStart = String.fromEnvironment(
      'LAQTA_DEV_START',
      defaultValue: '',
    );
    final devStartPath = devStart.isEmpty
        ? ''
        : (devStart.startsWith('/') ? devStart : '/$devStart');
    return GoRouter(
      initialLocation: devStartPath.isNotEmpty ? devStartPath : Routes.splash,
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
                    role == AppConstants.roleVenueOwner ||
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
              return const Scaffold(
                body: Center(child: Text('Missing chat id')),
              );
            }
            final otherUserName =
                state.uri.queryParameters['name'] ?? 'Unknown';
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
          path: Routes.venues,
          name: Routes.nVenues,
          builder: (context, state) => const VenuesListScreen(),
        ),
        GoRoute(
          path: Routes.venueDetails,
          name: Routes.nVenueDetails,
          builder: (context, state) {
            final venueId = state.pathParameters['id'];
            if (venueId == null || venueId.isEmpty) {
              return const Scaffold(
                body: Center(child: Text('Missing venue id')),
              );
            }
            return VenueDetailsScreen(venueId: venueId);
          },
        ),
        GoRoute(
          path: Routes.venueBooking,
          name: Routes.nVenueBooking,
          builder: (context, state) {
            final venueId = state.pathParameters['id'];
            if (venueId == null || venueId.isEmpty) {
              return const Scaffold(
                body: Center(child: Text('Missing venue id')),
              );
            }
            return VenueBookingScreen(venueId: venueId);
          },
        ),
        GoRoute(
          path: Routes.locationDetails,
          name: Routes.nLocationDetails,
          builder: (context, state) {
            final locationId = state.pathParameters['id'];
            if (locationId == null || locationId.isEmpty) {
              return const Scaffold(
                body: Center(child: Text('Missing location id')),
              );
            }
            return PhotoLocationDetailsScreen(locationId: locationId);
          },
        ),
        GoRoute(
          path: Routes.subscriptionPlans,
          name: Routes.nSubscriptionPlans,
          builder: (context, state) => const SubscriptionPlansScreen(),
        ),
        GoRoute(
          path: Routes.sponsoredAd,
          name: Routes.nSponsoredAd,
          builder: (context, state) => const SponsoredAdScreen(),
        ),
        GoRoute(
          path: Routes.campaignAnalytics,
          name: Routes.nCampaignAnalytics,
          builder: (context, state) {
            final campaignId = state.pathParameters['id'];
            if (campaignId == null || campaignId.isEmpty) {
              return const Scaffold(
                body: Center(child: Text('Missing campaign id')),
              );
            }
            return CampaignAnalyticsScreen(campaignId: campaignId);
          },
        ),
        GoRoute(
          path: Routes.photographerVerification,
          name: Routes.nPhotographerVerification,
          builder: (context, state) => const PhotographerVerificationScreen(),
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
          path: Routes.deleteAccountPolicy,
          name: Routes.nDeleteAccountPolicy,
          builder: (context, state) =>
              const PolicyTermsScreen(type: PolicyType.deleteAccount),
        ),
        GoRoute(
          path: Routes.contentPolicy,
          name: Routes.nContentPolicy,
          builder: (context, state) =>
              const PolicyTermsScreen(type: PolicyType.content),
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

            if (!AppConstants.paymentsConfigured) {
              return PaymentScreen(
                bookingId: bookingId ?? '',
                amount: amount ?? 0,
                photographerName: photographerName,
                sessionType: sessionType,
              );
            }

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
    const devStart = String.fromEnvironment(
      'LAQTA_DEV_START',
      defaultValue: '',
    );
    final devStartPath = devStart.isEmpty
        ? ''
        : (devStart.startsWith('/') ? devStart : '/$devStart');
    const devLock = bool.fromEnvironment('LAQTA_DEV_LOCK', defaultValue: false);
    const devBypassAuth = bool.fromEnvironment(
      'LAQTA_DEV_BYPASS_AUTH',
      defaultValue: false,
    );
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
        kDebugMode &&
        devStartPath.isNotEmpty; // dev-only: allow deep-linking screens
    if (!languageSelected && !isLanguage && !shouldBypassLanguage) {
      return Routes.language;
    }
    if (isLanguage) {
      return null;
    }
    final hasValidBackendSession = await _sessionService.hasValidToken();
    final userId = await _sessionService.getUserId();
    if (!hasValidBackendSession || userId == null || userId.isEmpty) {
      await _clearPersistedProfileStatus();
      _cachedProfileUserId = null;
      _cachedProfileCompleted = null;
      _cachedProfileRole = null;
      _cachedProfileBlocked = null;

      if (kDebugMode && devBypassAuth) {
        if (isSplash) {
          return devStartPath.isNotEmpty ? devStartPath : Routes.main;
        }
        return null;
      }

      if (isSplash) return Routes.auth;
      if (isAuth || isSignUpDetails) return null;
      return Routes.auth;
    }

    final profileStatus = await _getProfileStatus(userId);
    final profileCompleted = profileStatus.completed;
    final role = profileStatus.role.trim();
    final hasRole = role.isNotEmpty;
    final inProfileFlow = isRole || isBasicInfo || isSignUpDetails;
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
      if (!isBasicInfo && !isSignUpDetails) {
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

    final prefs = await SharedPreferences.getInstance();
    final persisted = _readPersistedProfileStatus(prefs, userId);

    try {
      final result = await ProfileDependencies.getUserProfile()
          .call(userId: userId)
          .timeout(_profileStatusTimeout);
      if (!result.isSuccess) {
        throw StateError('profile lookup failed');
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
      await _persistProfileStatus(
        prefs,
        userId: userId,
        completed: completed,
        role: role,
        isBlocked: isBlocked,
      );
      return _ProfileStatus(
        completed: completed,
        role: role,
        isBlocked: isBlocked,
      );
    } catch (_) {
      if (persisted != null) {
        _cachedProfileUserId = userId;
        _cachedProfileCompleted = persisted.completed;
        _cachedProfileRole = persisted.role;
        _cachedProfileBlocked = persisted.isBlocked;
        return persisted;
      }
      _cachedProfileUserId = userId;
      _cachedProfileCompleted = false;
      _cachedProfileRole = '';
      _cachedProfileBlocked = false;
      return const _ProfileStatus(completed: false, role: '', isBlocked: false);
    }
  }

  static void invalidateProfileCache([String? userId]) {
    if (userId == null || userId == _cachedProfileUserId) {
      _cachedProfileUserId = null;
      _cachedProfileCompleted = null;
      _cachedProfileRole = null;
      _cachedProfileBlocked = null;
    }
  }

  static _ProfileStatus? _readPersistedProfileStatus(
    SharedPreferences prefs,
    String userId,
  ) {
    final cachedUserId = prefs.getString(AppConstants.keyProfileCacheUserId);
    if (cachedUserId != userId) return null;

    return _ProfileStatus(
      completed: prefs.getBool(AppConstants.keyProfileCacheCompleted) ?? false,
      role: prefs.getString(AppConstants.keyProfileCacheRole) ?? '',
      isBlocked: prefs.getBool(AppConstants.keyProfileCacheBlocked) ?? false,
    );
  }

  static Future<void> _persistProfileStatus(
    SharedPreferences prefs, {
    required String userId,
    required bool completed,
    required String role,
    required bool isBlocked,
  }) async {
    await prefs.setString(AppConstants.keyProfileCacheUserId, userId);
    await prefs.setBool(AppConstants.keyProfileCacheCompleted, completed);
    await prefs.setString(AppConstants.keyProfileCacheRole, role);
    await prefs.setBool(AppConstants.keyProfileCacheBlocked, isBlocked);
  }

  static Future<void> _clearPersistedProfileStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.keyProfileCacheUserId);
    await prefs.remove(AppConstants.keyProfileCacheCompleted);
    await prefs.remove(AppConstants.keyProfileCacheRole);
    await prefs.remove(AppConstants.keyProfileCacheBlocked);
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
      context.push(Routes.signUpDetails);
  static void goToRole(BuildContext context) => context.go(Routes.role);
  static void goToProfileSetup(BuildContext context) {
    ScaffoldMessenger.maybeOf(context)?.clearSnackBars();
    context.go(Routes.basicInfo);
  }

  static void goToBookings(BuildContext context) =>
      context.push(Routes.bookings);
  static void goToMyRequests(BuildContext context) =>
      context.push(Routes.requests);
  static void goToShop(BuildContext context) => context.push(Routes.shop);
  static void goToCreateRequest(BuildContext context) =>
      context.push(Routes.requestCreate);
  static void goToExplore(BuildContext context) => context.go(Routes.explore);
  static void goToVenues(BuildContext context) => context.push(Routes.venues);
  static void goToPolicy(BuildContext context) => context.push(Routes.policy);
  static void goToTerms(BuildContext context) => context.push(Routes.terms);
  static void goToDeleteAccountPolicy(BuildContext context) =>
      context.push(Routes.deleteAccountPolicy);
  static void goToContentPolicy(BuildContext context) =>
      context.push(Routes.contentPolicy);
  static void goToBookingPolicies(BuildContext context) =>
      context.push(Routes.bookingPolicies);
  static void goToProfile(BuildContext context) => context.go(Routes.profile);

  static void goToBasicInfo(BuildContext context, String role) {
    assert(role.isNotEmpty, 'role is required');
    final query = Uri(queryParameters: {'role': role}).query;
    context.go('${Routes.basicInfo}?$query');
  }

  static void goToPortfolioEditor(BuildContext context) =>
      context.push(Routes.portfolioEditor);

  static void goToSettings(BuildContext context) =>
      context.push(Routes.settings);

  static void goToChat(
    BuildContext context,
    String chatId,
    String otherUserName,
  ) {
    assert(chatId.isNotEmpty, 'chatId is required');
    final path = _resolvePath(Routes.chat, {'id': chatId});
    final encodedName = Uri.encodeComponent(otherUserName);
    context.push('$path?name=$encodedName');
  }

  static void goToBookingDetails(BuildContext context, String bookingId) {
    assert(bookingId.isNotEmpty, 'bookingId is required');
    context.push(_resolvePath(Routes.booking, {'id': bookingId}));
  }

  static void goToRequestDetails(BuildContext context, String requestId) {
    assert(requestId.isNotEmpty, 'requestId is required');
    context.push(_resolvePath(Routes.requestDetails, {'id': requestId}));
  }

  static void goToOfferSubmit(BuildContext context, String requestId) {
    assert(requestId.isNotEmpty, 'requestId is required');
    context.push(_resolvePath(Routes.offerSubmit, {'id': requestId}));
  }

  static void goToPhotographerProfile(
    BuildContext context,
    String photographerId,
  ) {
    assert(photographerId.isNotEmpty, 'photographerId is required');
    context.push(_resolvePath(Routes.photographer, {'id': photographerId}));
  }

  static void goToVenueDetails(BuildContext context, String venueId) {
    assert(venueId.isNotEmpty, 'venueId is required');
    context.push(_resolvePath(Routes.venueDetails, {'id': venueId}));
  }

  static void goToVenueBooking(BuildContext context, String venueId) {
    assert(venueId.isNotEmpty, 'venueId is required');
    context.push(_resolvePath(Routes.venueBooking, {'id': venueId}));
  }

  static void goToLocationDetails(BuildContext context, String locationId) {
    assert(locationId.isNotEmpty, 'locationId is required');
    context.push(_resolvePath(Routes.locationDetails, {'id': locationId}));
  }

  static void goToSubscriptionPlans(BuildContext context) =>
      context.push(Routes.subscriptionPlans);

  static void goToSponsoredAd(BuildContext context) =>
      context.push(Routes.sponsoredAd);

  static void goToCampaignAnalytics(BuildContext context, String campaignId) {
    assert(campaignId.isNotEmpty, 'campaignId is required');
    context.push(_resolvePath(Routes.campaignAnalytics, {'id': campaignId}));
  }

  static void goToPhotographerVerification(BuildContext context) =>
      context.push(Routes.photographerVerification);

  static void goToFavorites(BuildContext context) =>
      context.push(Routes.favorites);
  static void goToNotifications(BuildContext context) =>
      context.push(Routes.notifications);
  static void goToDashboard(BuildContext context) =>
      context.push(Routes.dashboard);
  static void goToSearch(BuildContext context) => context.push(Routes.search);
  static void goToLoyaltyPoints(BuildContext context) =>
      context.push(Routes.loyalty);
  static void goToAchievements(BuildContext context) =>
      context.push(Routes.achievements);
  static void goToAvailability(BuildContext context) =>
      context.push(Routes.availability);

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
    context.push('${Routes.writeReview}?$query');
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

    if (!AppConstants.paymentsConfigured) {
      final messenger = ScaffoldMessenger.maybeOf(context);
      if (messenger != null) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).paymentsUnavailable),
          ),
        );
      }
      return;
    }

    final query = Uri(
      queryParameters: {
        'bookingId': bookingId,
        'amount': amount.toString(),
        'photographerName': photographerName,
        'sessionType': sessionType,
      },
    ).query;
    context.push('${Routes.payment}?$query');
  }

  static void goToCreatePost(BuildContext context) =>
      context.push(Routes.createPost);

  static void goToCreateStory(BuildContext context) =>
      context.push(Routes.createStory);

  static String _resolvePath(String template, Map<String, String> params) {
    var resolved = template;
    params.forEach((key, value) {
      resolved = resolved.replaceFirst(':$key', Uri.encodeComponent(value));
    });
    return resolved;
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
