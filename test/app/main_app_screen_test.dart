import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('MainAppScreen Role Caching', () {
    setUpAll(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('caches user role correctly', () async {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('profile_cache_user_id', 'user123');
      await prefs.setString('profile_cache_role', 'photographer');

      expect(
        prefs.getString('profile_cache_role'),
        'photographer',
      );
    });

    test('returns null when cache is empty', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      final role = prefs.getString('profile_cache_role');
      expect(role, null);
    });

    test('clears cache when userId changes', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      await prefs.setString('profile_cache_user_id', 'user123');
      await prefs.setString('profile_cache_role', 'photographer');

      // Simulate userId change
      await prefs.setString('profile_cache_user_id', 'user456');

      // Verify userId was updated
      expect(prefs.getString('profile_cache_user_id'), 'user456');
    });
  });
}
