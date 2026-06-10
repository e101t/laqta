import 'package:flutter/material.dart';
import 'laqta_tokens.dart';
import 'laqta_typography.dart';

class LaqtaTheme {
  static ThemeData light({bool isArabic = true}) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: LaqtaColors.primary,
      brightness: Brightness.light,
      primary: LaqtaColors.primary,
      secondary: LaqtaColors.accent,
      surface: LaqtaColors.surface,
      error: LaqtaColors.error,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: LaqtaColors.canvas,
      textTheme: LaqtaTypography.textTheme(isArabic: isArabic),
      appBarTheme: AppBarTheme(
        backgroundColor: LaqtaColors.canvas,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: LaqtaTypography.textTheme(
          isArabic: isArabic,
        ).titleMedium?.copyWith(color: LaqtaColors.ink),
        iconTheme: const IconThemeData(color: LaqtaColors.ink),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: LaqtaColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LaqtaRadii.m),
          borderSide: const BorderSide(color: LaqtaColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LaqtaRadii.m),
          borderSide: const BorderSide(color: LaqtaColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LaqtaRadii.m),
          borderSide: const BorderSide(color: LaqtaColors.primary, width: 1.4),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: LaqtaColors.surface,
        elevation: 6,
        indicatorColor: LaqtaColors.primary.withValues(alpha: 0.12),
        labelTextStyle: WidgetStateProperty.all(
          LaqtaTypography.textTheme(isArabic: isArabic).labelSmall,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: LaqtaColors.ink,
        contentTextStyle: LaqtaTypography.textTheme(
          isArabic: isArabic,
        ).bodyMedium?.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LaqtaRadii.m),
        ),
        elevation: 4,
        insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
      ),
      cardTheme: CardThemeData(
        color: LaqtaColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LaqtaRadii.l),
        ),
      ),
    );
  }

  static ThemeData dark({bool isArabic = true}) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: LaqtaColors.accent,
      brightness: Brightness.dark,
      primary: LaqtaColors.accent,
      secondary: LaqtaColors.primary,
      surface: LaqtaColors.surfaceDark,
      error: LaqtaColors.error,
    );

    final textTheme = LaqtaTypography.textTheme(
      isArabic: isArabic,
    ).apply(bodyColor: LaqtaColors.inkDark, displayColor: LaqtaColors.inkDark);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: LaqtaColors.canvasDark,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: LaqtaColors.surfaceDark,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleMedium?.copyWith(
          color: LaqtaColors.inkDark,
        ),
        iconTheme: const IconThemeData(color: LaqtaColors.inkDark),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: LaqtaColors.surfaceDark,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LaqtaRadii.m),
          borderSide: const BorderSide(color: LaqtaColors.borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LaqtaRadii.m),
          borderSide: const BorderSide(color: LaqtaColors.borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LaqtaRadii.m),
          borderSide: const BorderSide(color: LaqtaColors.primary, width: 1.4),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: LaqtaColors.surfaceDark,
        elevation: 6,
        indicatorColor: LaqtaColors.accent.withValues(alpha: 0.25),
        labelTextStyle: WidgetStateProperty.all(
          textTheme.labelSmall?.copyWith(color: LaqtaColors.inkMutedDark),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF171A20),
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LaqtaRadii.m),
        ),
        elevation: 4,
        insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: LaqtaColors.accent,
          foregroundColor: Colors.black,
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: LaqtaColors.surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LaqtaRadii.l),
        ),
      ),
    );
  }
}
