import 'package:flutter/material.dart';

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
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
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
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
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
      title: 'لا توجد حجوزات',
      message: 'لم تقم بأي حجوزات بعد.\nابدأ بالبحث عن مصورك المفضل!',
      emoji: '📅',
      actionLabel: 'تصفح المصورين',
      onAction: onBrowse,
    );
  }

  static Widget noFavorites({VoidCallback? onExplore}) {
    return EmptyState(
      icon: Icons.favorite_border,
      title: 'لا توجد مفضلات',
      message: 'لم تضف أي مصور للمفضلة بعد.\nاستكشف المصورين وأضفهم!',
      emoji: '❤️',
      actionLabel: 'استكشف الآن',
      onAction: onExplore,
    );
  }

  static Widget noChats({VoidCallback? onStart}) {
    return EmptyState(
      icon: Icons.chat_bubble_outline,
      title: 'لا توجد محادثات',
      message: 'لم تبدأ أي محادثة بعد.\nابدأ محادثة مع مصور!',
      emoji: '💬',
      actionLabel: 'ابحث عن مصور',
      onAction: onStart,
    );
  }

  static Widget noNotifications() {
    return const EmptyState(
      icon: Icons.notifications_none,
      title: 'لا توجد إشعارات',
      message: 'لم تستلم أي إشعارات بعد.\nسنخبرك عند وجود جديد!',
      emoji: '🔔',
    );
  }

  static Widget noSearchResults({String? query}) {
    return EmptyState(
      icon: Icons.search_off,
      title: 'لا توجد نتائج',
      message: query != null
          ? 'لم نجد نتائج لـ "$query".\nجرب كلمات بحث أخرى!'
          : 'لم نجد أي نتائج.\nجرب تغيير الفلاتر!',
      emoji: '🔍',
    );
  }

  static Widget noStories() {
    return const EmptyState(
      icon: Icons.photo_library_outlined,
      title: 'لا توجد قصص',
      message: 'لا توجد قصص جديدة الآن.\nتابع المصورين لمشاهدة قصصهم!',
      emoji: '📸',
    );
  }

  static Widget noReviews({VoidCallback? onWrite}) {
    return EmptyState(
      icon: Icons.rate_review_outlined,
      title: 'لا توجد تقييمات',
      message: 'لم يتم كتابة أي تقييمات بعد.\nكن أول من يقيّم!',
      emoji: '⭐',
      actionLabel: 'اكتب تقييم',
      onAction: onWrite,
    );
  }

  static Widget noPortfolio({VoidCallback? onUpload}) {
    return EmptyState(
      icon: Icons.photo_camera_outlined,
      title: 'لا توجد أعمال',
      message: 'لم تضف أي أعمال لمعرضك بعد.\nابدأ بإضافة صورك!',
      emoji: '🎨',
      actionLabel: 'إضافة صور',
      onAction: onUpload,
    );
  }

  static Widget noTransactions() {
    return const EmptyState(
      icon: Icons.receipt_long_outlined,
      title: 'لا توجد معاملات',
      message: 'لم تجري أي معاملات مالية بعد.\nستظهر هنا عند إتمام حجز!',
      emoji: '💰',
    );
  }

  static Widget error({String? message, VoidCallback? onRetry}) {
    return EmptyState(
      icon: Icons.error_outline,
      title: 'حدث خطأ',
      message: message ?? 'حدث خطأ ما.\nيرجى المحاولة مرة أخرى!',
      emoji: '⚠️',
      actionLabel: 'إعادة المحاولة',
      onAction: onRetry,
    );
  }

  static Widget offline({VoidCallback? onRetry}) {
    return EmptyState(
      icon: Icons.wifi_off,
      title: 'لا يوجد اتصال',
      message: 'يرجى التحقق من اتصالك بالإنترنت\nوالمحاولة مرة أخرى!',
      emoji: '📡',
      actionLabel: 'إعادة المحاولة',
      onAction: onRetry,
    );
  }
}
