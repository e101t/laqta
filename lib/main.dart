import 'dart:async';
import 'package:laqta/core/logging/app_logger.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:laqta/core/constants/app_constants.dart';
import 'package:laqta/app/router/app_router.dart';
import 'package:laqta/core/analytics/analytics_service.dart';
import 'package:laqta/core/launch/launch_gate.dart';
import 'package:laqta/core/localization/app_localizations.dart';
import 'package:laqta/core/monitoring/crash_reporter.dart';
import 'package:laqta/core/monitoring/sentry_flutter_service.dart';
import 'package:laqta/core/network/connectivity/offline_banner.dart';
import 'package:laqta/core/providers/theme_provider.dart';
import 'package:laqta/core/providers/locale_provider.dart';
import 'package:laqta/core/presentation/widgets/error_boundary.dart';
import 'package:laqta/core/config/remote_config_service.dart';
import 'package:laqta/core/routing/deep_link_handler.dart';
import 'package:laqta/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:laqta/core/auth/biometric/biometric_guard.dart';
import 'package:laqta/core/auth/session/anomaly_detector.dart';
import 'package:laqta/core/auth/token_manager.dart';
import 'package:laqta/core/security/monitoring/security_health.dart';
import 'package:laqta/core/network/certificate_pinning.dart';
import 'package:laqta/core/security/device_security_checker.dart';
import 'package:laqta/core/security/integrity_checker.dart';
import 'package:laqta/core/security/rasp/rasp_coordinator.dart';
import 'package:laqta/core/security/screen_security.dart';
import 'package:laqta/core/services/notification_navigation_service.dart';
import 'package:laqta/core/update/force_update_dialog.dart';
import 'package:laqta/features/auth/data/services/backend_auth_exchange_service.dart';
import 'package:laqta/features/notifications/data/fcm_service.dart';
import 'package:laqta/features/notifications/presentation/widgets/in_app_notification_banner.dart';
import 'package:provider/provider.dart';
import 'package:laqta/features/downloads/downloads_dependencies.dart';
import 'package:laqta/features/downloads/presentation/providers/download_provider.dart';

final DeepLinkHandler _deepLinkHandler = DeepLinkHandler();

void main() {
  runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      FlutterError.onError = (details) {
        CrashReporter.logFatal(details.exception, details.stack);
        if (kDebugMode) {
          FlutterError.presentError(details);
        }
      };
      PlatformDispatcher.instance.onError = (error, stack) {
        CrashReporter.logFatal(error, stack);
        return true;
      };
      await _bootstrap();
    },
    (error, stack) {
      CrashReporter.logFatal(error, stack);
    },
  );
}

Future<void> _bootstrap() async {
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  await ScreenSecurity.enableSecureScreens();
  await SentryFlutterService.initialize();
  await TokenManager().prepareForStartup();
  unawaited(RaspCoordinator.instance.runAllChecks(logoutOnCritical: true));

  Object? startupError;

  // Firebase is initialized only for FCM push notifications.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(const Duration(seconds: 10));
  } catch (e) {
    startupError = e;
    if (kDebugMode) {
      AppLogger.d('runtime', 'Firebase Messaging initialization error: $e');
    }
  }

  if (startupError != null) {
    runApp(StartupFailureApp(error: startupError.toString()));
    return;
  }

  runApp(const LaqtaApp());
  unawaited(_initializeDeferredServices());
  unawaited(AnalyticsService.instance.track('app_open', screen: 'startup'));
}

Future<void> _initializeDeferredServices() async {
  Future<void> guard(String label, Future<void> Function() task) async {
    try {
      await task().timeout(const Duration(seconds: 8));
    } catch (e) {
      if (kDebugMode) {
        AppLogger.d('runtime', '$label initialization error: $e');
      }
    }
  }

  await guard('Backend session', () async {
    await BackendAuthExchangeService().ensureBackendSession();
  });

  await guard('Remote feature flags', () async {
    await RemoteConfigService().load();
  });

  await guard('Play Integrity warm-up', () async {
    await IntegrityChecker.instance.warmUp();
  });

  await guard('Device security check', () async {
    await DeviceSecurityChecker.check();
  });

  await guard('RASP check', () async {
    await RaspCoordinator.instance.runAllChecks(logoutOnCritical: true);
    SecurityHealth.instance.start();
  });

  await guard('Firebase Messaging auto-init', () async {
    await FirebaseMessaging.instance.setAutoInitEnabled(true);
  });

  await guard('Notification sync', () async {
    await FcmService.instance.initialize();
  });

  await guard('Notification navigation', () async {
    await NotificationNavigationService.instance.initialize();
  });

  await guard('Deep link navigation', () async {
    await _deepLinkHandler.initialize(AppRouter.router);
  });

  WidgetsBinding.instance.addPostFrameCallback((_) {
    NotificationNavigationService.instance.flushPendingLaunchMessage();
    _deepLinkHandler.flushPendingInitialLink();
  });
}

class LaqtaApp extends StatelessWidget {
  const LaqtaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(
          create: (_) => DownloadProvider(
            generateLinksUseCase: DownloadsDependencies.generateDownloadLinks(),
            extendLinkUseCase: DownloadsDependencies.extendDownloadLink(),
            getLinksUseCase: DownloadsDependencies.getDownloadLinks(),
          ),
        ),
      ],
      child: Consumer2<ThemeProvider, LocaleProvider>(
        builder: (context, themeProvider, localeProvider, child) {
          final locale = localeProvider.locale;
          return MaterialApp.router(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: themeProvider.themeFor(locale),
            darkTheme: themeProvider.darkThemeFor(locale),
            themeMode: themeProvider.themeMode,
            routerConfig: AppRouter.router,
            builder: (context, child) => ErrorBoundary(
              child: OfflineBanner(
                child: ForceUpdateGate(
                  child: LaunchGate(
                    child: InAppNotificationBannerHost(
                      child: CertificatePinningMaintenanceGate(
                        child: RaspSecurityGate(
                          child: DeviceSecurityWarningGate(
                            child: child ?? const SizedBox.shrink(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('ar', ''), Locale('en', '')],
            locale: locale,
          );
        },
      ),
    );
  }
}

class RaspSecurityGate extends StatefulWidget {
  const RaspSecurityGate({super.key, required this.child});

  final Widget child;

  @override
  State<RaspSecurityGate> createState() => _RaspSecurityGateState();
}

class _RaspSecurityGateState extends State<RaspSecurityGate>
    with WidgetsBindingObserver {
  String? _lastMessageShown;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    RaspCoordinator.latestStatus.addListener(_maybeShowSecurityDialog);
  }

  @override
  void dispose() {
    RaspCoordinator.latestStatus.removeListener(_maybeShowSecurityDialog);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      BiometricGuard.instance.markBackgrounded();
      SessionAnomalyDetector.instance.markBackgrounded();
      return;
    }
    if (state == AppLifecycleState.resumed) {
      unawaited(RaspCoordinator.instance.runAllChecks(logoutOnCritical: true));
    }
  }

  void _maybeShowSecurityDialog() {
    final status = RaspCoordinator.latestStatus.value;
    if (!mounted || status == null || status.isClean) {
      return;
    }
    final message = status.userMessage;
    if (message.isEmpty || _lastMessageShown == message) {
      return;
    }
    _lastMessageShown = message;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('تنبيه أمني'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('حسنًا'),
            ),
          ],
        ),
      );
      if (!mounted) return;
      if (status.requiresImmediateLogout) {
        AppRouter.goToAuth(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class DeviceSecurityWarningGate extends StatefulWidget {
  const DeviceSecurityWarningGate({super.key, required this.child});

  final Widget child;

  @override
  State<DeviceSecurityWarningGate> createState() =>
      _DeviceSecurityWarningGateState();
}

class _DeviceSecurityWarningGateState extends State<DeviceSecurityWarningGate> {
  bool _shown = false;

  @override
  void initState() {
    super.initState();
    DeviceSecurityChecker.latestReport.addListener(_maybeShowWarning);
  }

  @override
  void dispose() {
    DeviceSecurityChecker.latestReport.removeListener(_maybeShowWarning);
    super.dispose();
  }

  void _maybeShowWarning() {
    if (_shown || !mounted) return;
    final report = DeviceSecurityChecker.latestReport.value;
    if (report == null || !report.shouldWarnUser) return;
    _shown = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('تنبيه أمني'),
          content: const Text(
            'تم اكتشاف بيئة جهاز غير موثوقة. بعض العمليات الحساسة قد تكون مقيدة لحماية حسابك.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('متابعة'),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class StartupFailureApp extends StatelessWidget {
  const StartupFailureApp({super.key, required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Firebase Messaging startup failed.\n$error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

