import 'package:flutter/material.dart';

enum RequestValidationError { dateTime, budget, location }

class RequestValidation {
  static RequestValidationError? validate({
    required DateTime? date,
    required TimeOfDay? time,
    double? budgetMin,
    double? budgetMax,
    double? latitude,
    double? longitude,
    String? label,
    DateTime? now,
  }) {
    if (!isFutureDateTime(date: date, time: time, now: now)) {
      return RequestValidationError.dateTime;
    }
    if (!isBudgetRangeValid(min: budgetMin, max: budgetMax)) {
      return RequestValidationError.budget;
    }
    if (!isLocationValid(
      latitude: latitude,
      longitude: longitude,
      label: label,
    )) {
      return RequestValidationError.location;
    }
    return null;
  }

  static bool isFutureDateTime({
    required DateTime? date,
    required TimeOfDay? time,
    DateTime? now,
  }) {
    if (date == null || time == null) {
      return false;
    }
    final current = now ?? DateTime.now();
    final selected = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    return selected.isAfter(current);
  }

  static bool isBudgetRangeValid({double? min, double? max}) {
    if (min != null && min < 0) return false;
    if (max != null && max < 0) return false;
    if (min != null && max != null && max < min) return false;
    return true;
  }

  static bool isLocationValid({
    double? latitude,
    double? longitude,
    String? label,
  }) {
    final hasLabel = label != null && label.trim().isNotEmpty;
    final hasLat = latitude != null;
    final hasLng = longitude != null;
    if (!hasLabel && !hasLat && !hasLng) return true;
    return hasLat && hasLng;
  }
}
