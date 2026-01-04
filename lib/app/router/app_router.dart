import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
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
import 'package:luqta/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:luqta/features/onboarding/presentation/screens/splash_screen.dart';

import 'package:luqta/features/role/presentation/screens/role_picker_screen.dart';
import 'package:luqta/features/profile/presentation/screens/basic_info_screen.dart';
import 'package:luqta/features/profile/presentation/screens/portfolio_editor_screen.dart';
import 'package:luqta/features/profile/presentation/screens/profile_screen.dart';

import 'package:luqta/features/search/presentation/screens/search_screen.dart';
import 'package:luqta/features/chat/presentation/screens/chat_screen.dart';
import 'package:luqta/features/booking/presentation/screens/booking_details_screen.dart';
import 'package:luqta/features/booking/presentation/screens/my_bookings_screen.dart';
import 'package:luqta/features/payment/presentation/screens/payment_screen.dart';

import 'package:luqta/features/photographer/presentation/screens/photographer_profile_screen.dart';
import 'package:luqta/features/dashboard/presentation/screens/photographer_dashboard_screen.dart';
import 'package:luqta/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:luqta/features/favorites/presentation/screens/favorites_screen.dart';
import 'package:luqta/features/settings/presentation/screens/settings_screen.dart';
import 'package:luqta/features/settings/presentation/screens/policy_terms_screen.dart';

import 'package:luqta/features/analytics/presentation/screens/analytics_dashboard_screen.dart';
import 'package:luqta/features/achievements/presentation/screens/achievements_screen.dart';
import 'package:luqta/features/loyalty/presentation/screens/loyalty_points_screen.dart';
import 'package:luqta/features/photographer/presentation/screens/availability_screen.dart';
import 'package:luqta/features/review/presentation/screens/write_review_screen.dart';

class AppRouter {
  static String? _cachedProfileUserId;
  static bool? _cachedProfileCompleted;
  static String? _cachedProfileRole;
  static bool? _overrideOnboardingSeen;
  static bool _splashDelayComplete = false;
  static Future<void>? _splashDelayFuture;

  static final GoRouter router = GoRouter(
    initialLocation: Routes.splash,
    refreshListenable: GoRouterRefreshStream(
      FirebaseAuth.instance.authStateChanges(),
    ),
    redirect: _guardRedirect,
    routes: [
      GoRoute(
        path: Routes.splash,
        name: Routes.nSplash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: Routes.onboarding,
        name: Routes.nOnboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: Routes.auth,
        name: Routes.nAuth,
        builder: (context, state) => const AuthScreen(),
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
          final role =
              state.uri.queryParameters['role'] ?? AppConstants.roleCustomer;
          return BasicInfoScreen(userRole: role);
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
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.uri.path}')),
    ),
  );

  static Future<String?> _guardRedirect(
    BuildContext context,
    GoRouterState state,
  ) async {
    final path = state.uri.path;

    final isSplash = path == Routes.splash;
    final isOnboarding = path == Routes.onboarding;
    final isAuth = path == Routes.auth;
    final isRole = path == Routes.role;
    final isBasicInfo = path == Routes.basicInfo;

    if (isSplash && !_splashDelayComplete) {
      _splashDelayFuture ??= Future.delayed(
        const Duration(milliseconds: AppConstants.splashDuration),
      );
      await _splashDelayFuture;
      _splashDelayComplete = true;
    }

    final prefs = await SharedPreferences.getInstance();
    final onboardingSeen =
        _overrideOnboardingSeen ??
        (prefs.getBool(AppConstants.keyOnboardingSeen) ?? false);

    // Force onboarding first time
    if (!onboardingSeen && !isOnboarding) {
      return Routes.onboarding;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _cachedProfileUserId = null;
      _cachedProfileCompleted = null;

      if (isOnboarding && onboardingSeen) return Routes.auth;
      if (isSplash || isOnboarding || isAuth) return null;
      return Routes.auth;
    }

    final profileStatus = await _getProfileStatus(user.uid);
    final profileCompleted = profileStatus.completed;
    final role = profileStatus.role.trim();
    final hasRole = role.isNotEmpty;
    final inProfileFlow = isRole || isBasicInfo;

    if (isOnboarding && onboardingSeen) {
      if (profileCompleted) return Routes.main;
      if (!hasRole) return Routes.role;
      final query = Uri(queryParameters: {'role': role}).query;
      return '${Routes.basicInfo}?$query';
    }

    if (!profileCompleted) {
      if (!hasRole) {
        if (!isRole) return Routes.role;
      } else if (!isBasicInfo) {
        final query = Uri(queryParameters: {'role': role}).query;
        return '${Routes.basicInfo}?$query';
      }
    }

    if (profileCompleted && (isAuth || inProfileFlow || isOnboarding)) {
      return Routes.main;
    }

    return null;
  }

  static Future<_ProfileStatus> _getProfileStatus(String userId) async {
    if (_cachedProfileUserId == userId && _cachedProfileCompleted != null) {
      return _ProfileStatus(
        completed: _cachedProfileCompleted ?? false,
        role: _cachedProfileRole ?? '',
      );
    }

    final result = await ProfileDependencies.getUserProfile().call(
      userId: userId,
    );
    if (!result.isSuccess) {
      _cachedProfileUserId = userId;
      _cachedProfileCompleted = false;
      _cachedProfileRole = '';
      return const _ProfileStatus(completed: false, role: '');
    }

    final user = result.valueOrNull;
    final completed = user?.profileCompleted ?? false;
    final role = user?.role ?? '';
    _cachedProfileUserId = userId;
    _cachedProfileCompleted = completed;
    _cachedProfileRole = role;
    return _ProfileStatus(completed: completed, role: role);
  }

  static void invalidateProfileCache([String? userId]) {
    if (userId == null || userId == _cachedProfileUserId) {
      _cachedProfileUserId = null;
      _cachedProfileCompleted = null;
      _cachedProfileRole = null;
    }
  }

  static void markOnboardingSeen() {
    _overrideOnboardingSeen = true;
  }

  // Backward-compatible aliases (some screens may call AppRouter.settings etc.)
  static const String settings = Routes.settings;
  static const String availability = Routes.availability;
  static const String analytics = Routes.analytics;

  // Navigation helpers
  static void goToHome(BuildContext context) => context.go(Routes.main);
  static void goToAuth(BuildContext context) => context.go(Routes.auth);
  static void goToOnboarding(BuildContext context) =>
      context.go(Routes.onboarding);
  static void goToRole(BuildContext context) => context.go(Routes.role);

  static void goToBookings(BuildContext context) => context.go(Routes.bookings);
  static void goToPolicy(BuildContext context) => context.go(Routes.policy);
  static void goToTerms(BuildContext context) => context.go(Routes.terms);
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

  const _ProfileStatus({required this.completed, required this.role});
}
