import 'package:flutter/material.dart';
import 'package:luqta/core/constants/app_theme.dart';

/// Verified Badge Widget for verified photographers
class VerifiedBadge extends StatelessWidget {
  final double size;
  final bool showText;

  const VerifiedBadge({super.key, this.size = 20, this.showText = false});

  @override
  Widget build(BuildContext context) {
    if (showText) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.verified, color: AppColors.primary, size: size),
            const SizedBox(width: 6),
            Text(
              'موثّق',
              style: AppTypography.caption.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return Icon(Icons.verified, color: AppColors.primary, size: size);
  }
}
