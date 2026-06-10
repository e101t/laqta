import 'package:flutter/material.dart';

class LaqtaColors {
  // Luxury dark palette: deep ink + warm gold + soft ivory.
  static const Color primary = Color(0xFF1C2A3A);
  static const Color accent = Color(0xFFD6A44A);
  static const Color ink = Color(0xFF0F1215);
  static const Color inkMuted = Color(0xFF6E7178);
  static const Color canvas = Color(0xFFF5EFE6);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE6DDD2);
  static const Color inkDark = Color(0xFFF5F0E9);
  static const Color inkMutedDark = Color(0xFFB6AFA6);
  static const Color canvasDark = Color(0xFF141019);
  static const Color surfaceDark = Color(0xFF1D1713);
  static const Color borderDark = Color(0xFF332A22);
  static const Color success = Color(0xFF2BB673);
  static const Color warning = Color(0xFFF2B705);
  static const Color error = Color(0xFFE24A3B);

  static const Color glassFill = Color(0x12FFFFFF);
  static const Color glassBorder = Color(0x2AFFFFFF);
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
