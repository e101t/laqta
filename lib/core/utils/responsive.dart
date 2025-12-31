import 'package:flutter/material.dart';

enum DeviceType { phone, tablet, desktop }

class Responsive {
  static const double tabletBreakpoint = 600;
  static const double desktopBreakpoint = 1024;
  static const double wideLayoutBreakpoint = 900;

  static DeviceType deviceType(BuildContext context) {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    if (shortestSide >= desktopBreakpoint) {
      return DeviceType.desktop;
    }
    if (shortestSide >= tabletBreakpoint) {
      return DeviceType.tablet;
    }
    return DeviceType.phone;
  }

  static bool isDesktop(BuildContext context) {
    return deviceType(context) == DeviceType.desktop;
  }

  static bool isWideLayout(BuildContext context) {
    return MediaQuery.of(context).size.width >= wideLayoutBreakpoint;
  }
}
