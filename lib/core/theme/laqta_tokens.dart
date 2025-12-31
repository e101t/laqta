import 'package:flutter/material.dart';

class LaqtaColors {
  static const Color primary = Color(0xFF4DB6E5);
  static const Color accent = Color(0xFFFFA726);
  static const Color ink = Color(0xFF0E1116);
  static const Color inkMuted = Color(0xFF6B7280);
  static const Color canvas = Color(0xFFF7F8FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE6E8EC);
  static const Color inkDark = Color(0xFFF3F4F6);
  static const Color inkMutedDark = Color(0xFF9CA3AF);
  static const Color canvasDark = Color(0xFF0B0E13);
  static const Color surfaceDark = Color(0xFF11151A);
  static const Color borderDark = Color(0xFF1F2937);
  static const Color success = Color(0xFF28C76F);
  static const Color warning = Color(0xFFF2B705);
  static const Color error = Color(0xFFE74C3C);

  static const Color glassFill = Color(0x1FFFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);
}

class LaqtaRadii {
  static const double xs = 8;
  static const double s = 12;
  static const double m = 16;
  static const double l = 24;
  static const double xl = 32;
}

class LaqtaShadows {
  static const List<BoxShadow> soft = [
    BoxShadow(color: Color(0x14000000), blurRadius: 16, offset: Offset(0, 8)),
  ];

  static const List<BoxShadow> glass = [
    BoxShadow(color: Color(0x1F000000), blurRadius: 24, offset: Offset(0, 12)),
  ];
}

class LaqtaGlass {
  static const double blurSigma = 16;
  static const double opacity = 0.14;
  static const double borderOpacity = 0.28;
}
