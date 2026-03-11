import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:luqta/core/constants/app_constants.dart';
import 'package:luqta/app/router/app_router.dart';
import 'package:luqta/core/localization/app_localizations.dart';
import 'package:luqta/core/providers/theme_provider.dart';
import 'package:luqta/core/providers/locale_provider.dart';
import 'package:luqta/firebase_options.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:luqta/core/services/backend_notification_sync_service.dart';
import 'package:luqta/features/auth/data/services/backend_auth_exchange_service.dart';
import 'package:provider/provider.dart';
import 'package:luqta/features/downloads/downloads_dependencies.dart';
import 'package:luqta/features/downloads/presentation/providers/download_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Initialize Firebase with error handling
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    final shouldEnableAppCheck =
        AppConstants.enableAppCheck &&
        (!kDebugMode || AppConstants.forceDebugAppCheck);
    if (AppConstants.useFirebaseEmulators) {
      await _connectFirebaseEmulators();
    } else if (shouldEnableAppCheck) {
      await FirebaseAppCheck.instance.activate(
        providerAndroid: kDebugMode
            ? const AndroidDebugProvider()
            : const AndroidPlayIntegrityProvider(),
        providerApple: kDebugMode
            ? const AppleDebugProvider()
            : const AppleDeviceCheckProvider(),
      );
    }
  } catch (e) {
    if (kDebugMode) {
      debugPrint('Firebase initialization error: $e');
    }
  }

  try {
    await BackendAuthExchangeService().ensureBackendSession();
    await FirebaseMessaging.instance.setAutoInitEnabled(true);
    await BackendNotificationSyncService.instance.initialize();
  } catch (e) {
    if (kDebugMode) {
      debugPrint('Notification sync initialization error: $e');
    }
  }

  runApp(const LuqtaApp());
}

Future<void> _connectFirebaseEmulators() async {
  final host = Platform.isAndroid ? '10.0.2.2' : 'localhost';
  FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
  FirebaseAuth.instance.useAuthEmulator(host, 9099);
  FirebaseStorage.instance.useStorageEmulator(host, 9199);
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: false,
    sslEnabled: false,
  );
}

class LuqtaApp extends StatelessWidget {
  const LuqtaApp({super.key});

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
            builder: (context, child) => child ?? const SizedBox.shrink(),
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
