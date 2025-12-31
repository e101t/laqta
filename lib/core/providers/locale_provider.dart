import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('ar', '');
  static const String _localeKey = 'language';

  Locale get locale => _locale;

  LocaleProvider() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_localeKey) ?? 'ar';
    _locale = Locale(languageCode, '');
    notifyListeners();
  }

  Future<void> setLocale(String languageCode) async {
    _locale = Locale(languageCode, '');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, languageCode);
    notifyListeners();
  }
}
