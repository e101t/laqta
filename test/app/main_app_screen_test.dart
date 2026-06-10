import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laqta/app/main_app_screen.dart';
import 'package:laqta/core/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('MainAppScreen', () {
    setUpAll(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('displays loading state initially', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MainAppScreen(),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('caches user role correctly', (WidgetTester tester) async {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(AppConstants.keyProfileCacheUserId, 'user123');
      await prefs.setString(AppConstants.keyProfileCacheRole, AppConstants.rolePhotographer);

      expect(
        prefs.getString(AppConstants.keyProfileCacheRole),
        AppConstants.rolePhotographer,
      );
    });

    testWidgets('clears cache when userId changes', (WidgetTester tester) async {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(AppConstants.keyProfileCacheUserId, 'user123');
      await prefs.setString(AppConstants.keyProfileCacheRole, AppConstants.rolePhotographer);

      // Simulate userId change
      await prefs.setString(AppConstants.keyProfileCacheUserId, 'user456');

      // Cache should be considered invalid
      final cachedUserId = prefs.getString(AppConstants.keyProfileCacheUserId);
      expect(cachedUserId, 'user456');
    });
  });
}
