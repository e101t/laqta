import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:luqta/core/providers/theme_provider.dart';
import 'package:luqta/core/providers/locale_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('ThemeProvider loads light mode by default', () async {
    final provider = ThemeProvider();
    await Future.delayed(const Duration(milliseconds: 10));

    expect(provider.isDarkMode, isFalse);
    expect(provider.themeMode, ThemeMode.light);
    expect(provider.themeFor(const Locale('en')).brightness, Brightness.light);
  });

  test('ThemeProvider toggle persists choice', () async {
    final provider = ThemeProvider();
    await Future.delayed(const Duration(milliseconds: 10));

    await provider.toggleTheme();

    expect(provider.isDarkMode, isTrue);
    expect(provider.themeMode, ThemeMode.dark);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('isDarkMode'), isTrue);
  });

  test('LocaleProvider defaults to Arabic', () async {
    final provider = LocaleProvider();
    await Future.delayed(const Duration(milliseconds: 10));

    expect(provider.locale.languageCode, 'ar');
  });

  test('LocaleProvider updates and persists language', () async {
    final provider = LocaleProvider();
    await Future.delayed(const Duration(milliseconds: 10));

    await provider.setLocale('en');

    expect(provider.locale.languageCode, 'en');

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('language'), 'en');
  });
}
