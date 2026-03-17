import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:laqta/core/localization/app_localizations.dart';

/// Loading Indicator
class LoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;

  const LoadingIndicator({super.key, this.size = 40, this.color});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: 3,
          valueColor: AlwaysStoppedAnimation<Color>(color ?? scheme.primary),
        ),
      ),
    );
  }
}

/// Shimmer Loading Skeleton
class ShimmerBox extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const ShimmerBox({super.key, this.width, this.height, this.borderRadius});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final base = scheme.surfaceContainerHighest;
    final highlight = scheme.surface;
    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: base,
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
      ),
    );
  }
}

/// Photographer Card Skeleton
class PhotographerCardSkeleton extends StatelessWidget {
  const PhotographerCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ShimmerBox(
              height: 180,
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            const SizedBox(height: 12),
            const ShimmerBox(width: 150, height: 20),
            const SizedBox(height: 8),
            const ShimmerBox(width: 100, height: 14),
            const SizedBox(height: 12),
            Row(
              children: const [
                ShimmerBox(width: 60, height: 24),
                SizedBox(width: 8),
                ShimmerBox(width: 60, height: 24),
                SizedBox(width: 8),
                ShimmerBox(width: 60, height: 24),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// EmptyState moved to empty_states.dart to avoid duplication

/// Error State Widget
class ErrorState extends StatelessWidget {
  final String? title;
  final String? message;
  final VoidCallback? onRetry;

  const ErrorState({
    super.key,
    this.title,
    this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final effectiveTitle = title ?? localizations.somethingWentWrong;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: scheme.error.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 16),
            Text(
              effectiveTitle,
              style: textTheme.headlineSmall?.copyWith(
                color: scheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                style: textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(localizations.retry),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
