import 'dart:math' as math;
import 'package:laqta/core/localization/app_localizations.dart';

/// Calculates morning/evening golden-hour windows for Iraq (Baghdad centre).
///
/// Uses the NOAA simplified solar algorithm with Baghdad's coordinates:
///   Latitude  33.34 °N
///   Longitude 44.40 °E
///   UTC offset +3
///
/// Golden hour = the 60 minutes immediately after sunrise
///               and the 60 minutes immediately before sunset.
class GoldenHourService {
  GoldenHourService._();

  static const double _lat = 33.34;
  static const double _lon = 44.40;
  static const double _utcOffsetHours = 3.0;

  /// Returns the golden-hour state for [now] (defaults to DateTime.now()).
  static GoldenHourData compute([DateTime? now]) {
    final t = now ?? DateTime.now();
    final sunrise = _sunriseMinutes(t);
    final sunset = _sunsetMinutes(t);

    final currentMin = t.hour * 60 + t.minute;

    final morningStart = sunrise;
    final morningEnd = sunrise + 60;
    final eveningStart = sunset - 60;
    final eveningEnd = sunset;

    // Currently inside a golden hour window?
    if (currentMin >= morningStart && currentMin < morningEnd) {
      final endsAt = _minutesToTime(morningEnd);
      return GoldenHourData(
        isActive: true,
        label: AppLocalizations.current.goldenHourMorning,
        timeDisplay: AppLocalizations.current.endsAt(endsAt),
        sessionLabel: AppLocalizations.current.morningLabel,
      );
    }
    if (currentMin >= eveningStart && currentMin < eveningEnd) {
      final endsAt = _minutesToTime(eveningEnd);
      return GoldenHourData(
        isActive: true,
        label: AppLocalizations.current.goldenHourEvening,
        timeDisplay: AppLocalizations.current.endsAt(endsAt),
        sessionLabel: AppLocalizations.current.eveningLabel,
      );
    }

    // Not active — find next window
    if (currentMin < morningStart) {
      // Next: morning today
      final diff = morningStart - currentMin;
      return GoldenHourData(
        isActive: false,
        label: AppLocalizations.current.goldenHourNext,
        timeDisplay: _minutesToTime(morningStart),
        minutesUntil: diff,
        sessionLabel: AppLocalizations.current.morningLabel,
      );
    }
    if (currentMin < eveningStart) {
      // Next: evening today
      final diff = eveningStart - currentMin;
      return GoldenHourData(
        isActive: false,
        label: AppLocalizations.current.goldenHourNext,
        timeDisplay: _minutesToTime(eveningStart),
        minutesUntil: diff,
        sessionLabel: AppLocalizations.current.eveningLabel,
      );
    }
    // Past both windows — next is tomorrow's morning
    final tomorrowSunrise = _sunriseMinutes(t.add(const Duration(days: 1)));
    final diff = (24 * 60 - currentMin) + tomorrowSunrise;
    return GoldenHourData(
      isActive: false,
      label: AppLocalizations.current.goldenHourNext,
      timeDisplay: _minutesToTime(tomorrowSunrise),
      minutesUntil: diff,
      sessionLabel: AppLocalizations.current.tomorrowMorningLabel,
    );
  }

  // ── NOAA simplified algorithm ──────────────────────────────────────────────

  static int _sunriseMinutes(DateTime date) =>
      _sunEvent(date, rising: true);

  static int _sunsetMinutes(DateTime date) =>
      _sunEvent(date, rising: false);

  static int _sunEvent(DateTime date, {required bool rising}) {
    final dayOfYear = _dayOfYear(date);
    final b = 2 * math.pi / 365.0 * (dayOfYear - 1);
    // Equation of time (minutes)
    final eot = 229.18 *
        (0.000075 +
            0.001868 * math.cos(b) -
            0.032077 * math.sin(b) -
            0.014615 * math.cos(2 * b) -
            0.04089 * math.sin(2 * b));
    // Solar declination (radians)
    final decl = 0.006918 -
        0.399912 * math.cos(b) +
        0.070257 * math.sin(b) -
        0.006758 * math.cos(2 * b) +
        0.000907 * math.sin(2 * b);

    final latRad = _lat * math.pi / 180.0;
    // Hour angle at sunrise/sunset
    final cosHA = (math.cos(90.833 * math.pi / 180.0) -
            math.sin(latRad) * math.sin(decl)) /
        (math.cos(latRad) * math.cos(decl));
    final cosHAClamped = cosHA.clamp(-1.0, 1.0);
    final ha = math.acos(cosHAClamped) * 180.0 / math.pi; // degrees

    // UTC time of event in minutes
    final utcMin = rising
        ? 720 - 4 * (_lon + ha) - eot
        : 720 - 4 * (_lon - ha) - eot;

    // Local time (Iraq = UTC+3)
    return (utcMin + _utcOffsetHours * 60).round().clamp(0, 24 * 60 - 1);
  }

  static int _dayOfYear(DateTime date) {
    final start = DateTime(date.year, 1, 1);
    return date.difference(start).inDays + 1;
  }

  static String _minutesToTime(int totalMinutes) {
    final h = totalMinutes ~/ 60;
    final m = totalMinutes % 60;
    final period = h < 12 ? AppLocalizations.current.amMarker : AppLocalizations.current.pmMarker;
    final displayH = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '$displayH:${m.toString().padLeft(2, '0')} $period';
  }
}

class GoldenHourData {
  final bool isActive;
  final String label;
  final String timeDisplay;
  final String sessionLabel;

  /// Minutes until golden hour starts (0 when active).
  final int minutesUntil;

  const GoldenHourData({
    required this.isActive,
    required this.label,
    required this.timeDisplay,
    required this.sessionLabel,
    this.minutesUntil = 0,
  });

  String get countdownText {
    if (isActive) return timeDisplay;
    if (minutesUntil < 60) return AppLocalizations.current.inMinutes(minutesUntil);
    final h = minutesUntil ~/ 60;
    final m = minutesUntil % 60;
    if (m == 0) return AppLocalizations.current.inHours(h);
    return AppLocalizations.current.inHoursMinutes(h, m);
  }
}
