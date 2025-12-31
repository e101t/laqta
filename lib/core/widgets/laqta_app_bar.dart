import 'package:flutter/material.dart';
import '../theme/laqta_tokens.dart';
import '../theme/laqta_typography.dart';

class LAQTAAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onNotificationsTap;
  final VoidCallback? onAvatarTap;
  final String? avatarUrl;
  final bool showAvatar;

  const LAQTAAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.onNotificationsTap,
    this.onAvatarTap,
    this.avatarUrl,
    this.showAvatar = true,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppBar(
      titleSpacing: 16,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: textTheme.titleMedium),
          if (subtitle != null)
            Text(
              subtitle!,
              style: LaqtaTypography.textTheme(
                isArabic: Directionality.of(context) == TextDirection.rtl,
              ).labelSmall,
            ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none),
          onPressed: onNotificationsTap,
          tooltip: 'الإشعارات',
        ),
        if (showAvatar)
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: onAvatarTap,
              child: CircleAvatar(
                radius: 18,
                backgroundColor: LaqtaColors.border,
                backgroundImage: avatarUrl != null
                    ? NetworkImage(avatarUrl!)
                    : null,
                child: avatarUrl == null
                    ? const Icon(Icons.person_outline, color: LaqtaColors.ink)
                    : null,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 8);
}
