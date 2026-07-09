import 'package:flutter/material.dart';
import 'package:laqta/core/localization/app_localizations.dart';

/// Empty state widget for various scenarios
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String emoji;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.emoji = '🤔',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Animated emoji
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 800),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: Curves.elasticOut,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Text(emoji, style: const TextStyle(fontSize: 80)),
            );
          },
        ),
        const SizedBox(height: 24),

        // Icon
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: scheme.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 50, color: scheme.primary),
        ),
        const SizedBox(height: 24),

        // Title
        Text(
          title,
          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),

        // Message
        Text(
          message,
          style: textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),

        // Action button
        if (actionLabel != null && onAction != null)
          ElevatedButton.icon(
            onPressed: onAction,
            icon: const Icon(Icons.add_circle_outline),
            label: Text(actionLabel!),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        const padding = EdgeInsets.all(32);
        if (constraints.maxHeight.isFinite) {
          final minHeight = (constraints.maxHeight - padding.vertical)
              .clamp(0, double.infinity)
              .toDouble();
          return SingleChildScrollView(
            padding: padding,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: minHeight),
              child: Center(child: content),
            ),
          );
        }

        return Padding(
          padding: padding,
          child: Center(child: content),
        );
      },
    );
  }
}

/// Pre-configured empty states for common scenarios
class EmptyStates {
  static Widget noBookings({VoidCallback? onBrowse}) {
    return EmptyState(
      icon: Icons.calendar_today_outlined,
      title: AppLocalizations.current.emptyBookingsTitle,
      message: AppLocalizations.current.emptyBookingsMessage,
      emoji: '📅',
      actionLabel: AppLocalizations.current.browsePhotographers,
      onAction: onBrowse,
    );
  }

  static Widget noFavorites({VoidCallback? onExplore}) {
    return EmptyState(
      icon: Icons.favorite_border,
      title: AppLocalizations.current.emptyFavoritesTitle,
      message: AppLocalizations.current.emptyFavoritesMessage,
      emoji: '❤️',
      actionLabel: AppLocalizations.current.exploreNow,
      onAction: onExplore,
    );
  }

  static Widget noChats({VoidCallback? onStart}) {
    return EmptyState(
      icon: Icons.chat_bubble_outline,
      title: AppLocalizations.current.emptyChatsTitle,
      message: AppLocalizations.current.emptyChatsMessage,
      emoji: '💬',
      actionLabel: AppLocalizations.current.findPhotographer,
      onAction: onStart,
    );
  }

  static Widget noNotifications() {
    return EmptyState(
      icon: Icons.notifications_none,
      title: AppLocalizations.current.emptyNotificationsTitle,
      message: AppLocalizations.current.emptyNotificationsMessage,
      emoji: '🔔',
    );
  }

  static Widget noSearchResults({String? query}) {
    return EmptyState(
      icon: Icons.search_off,
      title: AppLocalizations.current.noResults,
      message: query != null
          ? AppLocalizations.current.emptySearchQuery(query)
          : AppLocalizations.current.emptySearchFiltersMessage,
      emoji: '🔍',
    );
  }

  static Widget noStories() {
    return EmptyState(
      icon: Icons.photo_library_outlined,
      title: AppLocalizations.current.emptyStoriesTitle,
      message: AppLocalizations.current.emptyStoriesMessage,
      emoji: '📸',
    );
  }

  static Widget noReviews({VoidCallback? onWrite}) {
    return EmptyState(
      icon: Icons.rate_review_outlined,
      title: AppLocalizations.current.emptyReviewsTitle,
      message: AppLocalizations.current.emptyReviewsMessage,
      emoji: '⭐',
      actionLabel: AppLocalizations.current.writeReviewAction,
      onAction: onWrite,
    );
  }

  static Widget noPortfolio({VoidCallback? onUpload}) {
    return EmptyState(
      icon: Icons.photo_camera_outlined,
      title: AppLocalizations.current.emptyPortfolioTitle,
      message: AppLocalizations.current.emptyPortfolioMessage,
      emoji: '🎨',
      actionLabel: AppLocalizations.current.addPhotosAction,
      onAction: onUpload,
    );
  }

  static Widget noTransactions() {
    return EmptyState(
      icon: Icons.receipt_long_outlined,
      title: AppLocalizations.current.emptyTransactionsTitle,
      message: AppLocalizations.current.emptyTransactionsMessage,
      emoji: '💰',
    );
  }

  static Widget error({String? message, VoidCallback? onRetry}) {
    return EmptyState(
      icon: Icons.error_outline,
      title: AppLocalizations.current.errorOccurredTitle,
      message: message ?? AppLocalizations.current.errorGenericMessage,
      emoji: '⚠️',
      actionLabel: AppLocalizations.current.retry,
      onAction: onRetry,
    );
  }

  static Widget offline({VoidCallback? onRetry}) {
    return EmptyState(
      icon: Icons.wifi_off,
      title: AppLocalizations.current.noConnectionTitle,
      message: AppLocalizations.current.noConnectionMessage,
      emoji: '📡',
      actionLabel: AppLocalizations.current.retry,
      onAction: onRetry,
    );
  }
}
