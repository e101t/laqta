import 'package:flutter/material.dart';
import 'laqta_tokens.dart';

class LaqtaTypography {
  static const String fontArabic = 'Tajawal';
  static const String fontEnglish = 'Poppins';

  static TextTheme textTheme({required bool isArabic}) {
    final base = Typography.material2021().black;
    final fontFamily = isArabic ? fontArabic : fontEnglish;

    return base.copyWith(
      titleLarge: base.titleLarge?.copyWith(
        fontFamily: fontFamily,
        fontSize: 24,
        height: 1.3,
        fontWeight: FontWeight.w700,
        color: LaqtaColors.ink,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontFamily: fontFamily,
        fontSize: 20,
        height: 1.3,
        fontWeight: FontWeight.w700,
        color: LaqtaColors.ink,
      ),
      titleSmall: base.titleSmall?.copyWith(
        fontFamily: fontFamily,
        fontSize: 16,
        height: 1.4,
        fontWeight: FontWeight.w600,
        color: LaqtaColors.ink,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        fontFamily: fontFamily,
        fontSize: 14,
        height: 1.6,
        color: LaqtaColors.ink,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontFamily: fontFamily,
        fontSize: 13,
        height: 1.5,
        color: LaqtaColors.inkMuted,
      ),
      labelSmall: base.labelSmall?.copyWith(
        fontFamily: fontFamily,
        fontSize: 12,
        height: 1.4,
        color: LaqtaColors.inkMuted,
      ),
    );
  }
}
