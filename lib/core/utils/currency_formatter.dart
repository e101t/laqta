import 'dart:ui';

import 'package:intl/intl.dart' as intl;
import 'package:laqta/core/constants/app_constants.dart';
import 'package:laqta/core/localization/app_localizations.dart';

/// Central money formatting so screens never hardcode "IQD"/"د.ع".
///
/// Launch market is Iraq (IQD, zero decimal digits). Adding a market means
/// adding a symbol entry here and passing the booking's currency code —
/// no per-screen changes.
class CurrencyFormatter {
  CurrencyFormatter._();

  static const Map<String, ({String ar, String en, int decimalDigits})>
  _currencies = {
    'IQD': (ar: 'د.ع', en: 'IQD', decimalDigits: 0),
    'USD': (ar: r'$', en: r'$', decimalDigits: 2),
  };

  static String format(
    num amount, {
    String currency = AppConstants.currencyIQD,
    Locale? locale,
  }) {
    final effectiveLocale = locale ?? AppLocalizations.current.locale;
    final isArabic = effectiveLocale.languageCode == 'ar';
    final info =
        _currencies[currency.toUpperCase()] ??
        (ar: currency, en: currency, decimalDigits: 2);
    final formatter = intl.NumberFormat.currency(
      locale: isArabic ? 'ar' : 'en',
      symbol: isArabic ? info.ar : info.en,
      decimalDigits: info.decimalDigits,
    );
    return formatter.format(amount);
  }
}
