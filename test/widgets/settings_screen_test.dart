import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luqta/core/localization/app_localizations.dart';
import 'package:luqta/core/providers/locale_provider.dart';
import 'package:luqta/core/providers/theme_provider.dart';
import 'package:luqta/features/settings/presentation/screens/settings_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'language': 'en',
      'isDarkMode': false,
      'notificationsEnabled': true,
      'reduceMotion': false,
    });
  });

  testWidgets('settings screen shows translated section labels', (
    tester,
  ) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ],
        child: Consumer2<ThemeProvider, LocaleProvider>(
          builder: (context, themeProvider, localeProvider, _) {
            return MaterialApp(
              locale: localeProvider.locale,
              supportedLocales: const [Locale('en'), Locale('ar')],
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              home: const SettingsScreen(),
            );
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Appearance'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Legal'), 200);
    await tester.pumpAndSettle();

    expect(find.text('Legal'), findsOneWidget);

    expect(find.text('notificationsSection'), findsNothing);
    expect(find.text('appearanceSection'), findsNothing);
    expect(find.text('darkModeSubtitle'), findsNothing);
    expect(find.text('reduceMotionSubtitle'), findsNothing);
    expect(find.text('legalSection'), findsNothing);
  });
}
