import 'package:flutter/material.dart';
import 'package:laqta/core/theme/laqta_tokens.dart';

class LaqtaLuxurySearchBar extends StatelessWidget {
  final String hint;
  final VoidCallback? onTap;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final bool readOnly;

  const LaqtaLuxurySearchBar({
    super.key,
    required this.hint,
    this.onTap,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.readOnly = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFF1C1E23),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF22252C)),
      ),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          readOnly: readOnly,
          onTap: onTap,
          onChanged: onChanged,
          textAlign: TextAlign.right,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.white),
          decoration: InputDecoration(
            border: InputBorder.none,
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: Color(0xFF8E8D92),
              size: 22,
            ),
            hintText: hint,
            hintStyle: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF8E8D92)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ),
    );
  }
}

class LaqtaSectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const LaqtaSectionHeader({
    super.key,
    required this.title,
    this.action,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
        if (action != null)
          TextButton(
            onPressed: onAction,
            child: Text(
              action!,
              style: textTheme.labelLarge?.copyWith(
                color: LaqtaColors.accent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }
}

class LaqtaLuxurySurface extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  const LaqtaLuxurySurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 22,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF17191F), Color(0xFF13151A)],
        ),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: const Color(0xFF2A2D33)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class LaqtaFeaturePill extends StatelessWidget {
  final IconData icon;
  final String label;

  const LaqtaFeaturePill({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF17191F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2D33)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: LaqtaColors.accent),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class LaqtaPrimaryAction extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool outlined;
  final IconData? icon;

  const LaqtaPrimaryAction({
    super.key,
    required this.label,
    this.onTap,
    this.outlined = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final bg = outlined ? Colors.transparent : LaqtaColors.accent;
    final fg = outlined ? Colors.white : Colors.black;
    return Expanded(
      child: SizedBox(
        height: 50,
        child: OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            backgroundColor: bg,
            foregroundColor: fg,
            side: BorderSide(
              color: outlined
                  ? LaqtaColors.accent.withValues(alpha: 0.8)
                  : Colors.transparent,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LaqtaTopIconButton extends StatelessWidget {
  final IconData icon;
  final bool badge;
  final VoidCallback? onTap;

  const LaqtaTopIconButton({
    super.key,
    required this.icon,
    this.badge = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ),
        if (badge)
          PositionedDirectional(
            top: 4,
            end: 4,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: const Color(0xFFFF5449),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF0E1014), width: 1.2),
              ),
            ),
          ),
      ],
    );
  }
}

class LaqtaHeaderBackButton extends StatelessWidget {
  final VoidCallback? onTap;
  final IconData icon;

  const LaqtaHeaderBackButton({
    super.key,
    this.onTap,
    this.icon = Icons.chevron_left_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ?? () => Navigator.of(context).maybePop(),
      borderRadius: BorderRadius.circular(999),
      child: SizedBox(
        width: 28,
        height: 28,
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}

class LaqtaHeroOverlayIconButton extends StatelessWidget {
  final VoidCallback? onTap;
  final IconData icon;

  const LaqtaHeroOverlayIconButton({super.key, this.onTap, required this.icon});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 34,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.28),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0x40FFFFFF)),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}

class LaqtaFilterPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const LaqtaFilterPill({
    super.key,
    required this.label,
    required this.selected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? LaqtaColors.accent : const Color(0xFF191B20),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? LaqtaColors.accent : const Color(0xFF2A2D33),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.black : Colors.white70,
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class LaqtaMetricColumn extends StatelessWidget {
  final String value;
  final String label;

  const LaqtaMetricColumn({
    super.key,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white60, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class LaqtaImageFrame extends StatelessWidget {
  final String imagePath;
  final double height;
  final BorderRadius borderRadius;
  final Widget? overlay;

  const LaqtaImageFrame({
    super.key,
    required this.imagePath,
    required this.height,
    required this.borderRadius,
    this.overlay,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: SizedBox(
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(imagePath, fit: BoxFit.cover),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.08),
                    Colors.black.withValues(alpha: 0.58),
                  ],
                ),
              ),
            ),
            ...?overlay == null ? null : [overlay!],
          ],
        ),
      ),
    );
  }
}

class LaqtaMarketplaceBottomNav extends StatelessWidget {
  final int activeIndex;
  final ValueChanged<int>? onTap;
  final VoidCallback? onPrimaryAction;

  const LaqtaMarketplaceBottomNav({
    super.key,
    required this.activeIndex,
    this.onTap,
    this.onPrimaryAction,
  });

  @override
  Widget build(BuildContext context) {
    const items = <(IconData, String)>[
      (Icons.home_rounded, 'الرئيسية'),
      (Icons.search_rounded, 'اكتشف'),
      (Icons.add_rounded, ''),
      (Icons.chat_bubble_outline_rounded, 'الرسائل'),
      (Icons.person_outline_rounded, 'الملف الشخصي'),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF111317),
        border: Border(top: BorderSide(color: Color(0xFF23262D))),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(
            textDirection: TextDirection.ltr,
            children: List.generate(items.length, (index) {
              if (index == 2) {
                return Expanded(
                  child: SizedBox(
                    height: 56,
                    child: Center(
                      child: GestureDetector(
                        onTap: onPrimaryAction,
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: LaqtaColors.accent,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: LaqtaColors.accent.withValues(
                                  alpha: 0.35,
                                ),
                                blurRadius: 18,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.add_rounded,
                            color: Colors.black,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }

              final selected = activeIndex == index;
              final item = items[index];
              final color = selected ? LaqtaColors.accent : Colors.white54;
              return Expanded(
                child: SizedBox(
                  height: 54,
                  child: InkWell(
                    onTap: () => onTap?.call(index),
                    borderRadius: BorderRadius.circular(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(item.$1, color: color, size: selected ? 23 : 22),
                        const SizedBox(height: 3),
                        Text(
                          item.$2,
                          style: TextStyle(
                            color: color,
                            fontSize: 10.5,
                            fontWeight: selected
                                ? FontWeight.w800
                                : FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
