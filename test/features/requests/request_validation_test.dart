import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luqta/features/requests/domain/utils/request_validation.dart';

void main() {
  test('isFutureDateTime rejects past selections', () {
    final now = DateTime(2026, 1, 28, 10, 0);
    final date = DateTime(2026, 1, 28);
    const time = TimeOfDay(hour: 9, minute: 0);

    final isValid = RequestValidation.isFutureDateTime(
      date: date,
      time: time,
      now: now,
    );

    expect(isValid, isFalse);
  });

  test('isBudgetRangeValid rejects negative or inverted budgets', () {
    expect(RequestValidation.isBudgetRangeValid(min: -1, max: 10), isFalse);
    expect(RequestValidation.isBudgetRangeValid(min: 200, max: 100), isFalse);
    expect(RequestValidation.isBudgetRangeValid(min: 100, max: 200), isTrue);
  });

  test('isLocationValid requires lat/lng together when provided', () {
    expect(
      RequestValidation.isLocationValid(latitude: 33.0, longitude: null),
      isFalse,
    );
    expect(
      RequestValidation.isLocationValid(latitude: 33.0, longitude: 44.0),
      isTrue,
    );
  });

  test('validate returns the first applicable error', () {
    final error = RequestValidation.validate(
      date: DateTime(2026, 1, 27),
      time: const TimeOfDay(hour: 8, minute: 0),
      budgetMin: 100,
      budgetMax: 50,
      latitude: null,
      longitude: null,
      label: null,
      now: DateTime(2026, 1, 28, 10, 0),
    );

    expect(error, RequestValidationError.dateTime);
  });
}
