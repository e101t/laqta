import 'package:flutter/material.dart';
import 'package:luqta/core/constants/app_theme.dart';
import 'package:luqta/core/localization/app_localizations.dart';

class AvailabilityScreen extends StatefulWidget {
  const AvailabilityScreen({super.key});

  @override
  State<AvailabilityScreen> createState() => _AvailabilityScreenState();
}

class _AvailabilityScreenState extends State<AvailabilityScreen> {
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(localizations.availability)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.calendar_month,
              size: 64,
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            Text(localizations.manageSlots, style: AppTypography.h2),
            const SizedBox(height: 8),
            Text(
              localizations.weeklyTemplate,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Availability management coming soon...',
              style: AppTypography.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
