import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import 'package:laqta/core/theme/laqta_tokens.dart';

/// A single destination in [FrostedNavBar].
class FrostedNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const FrostedNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

/// Frosted-glass bottom navigation bar.
///
/// Draws everything manually in a [Row] over a blurred backdrop —
/// no [NavigationBar] involved. When five or more items are supplied the
/// center slot becomes the primary action (gold circle) wired to
/// [onPrimaryAction]; otherwise the primary action is appended at the end.
class FrostedNavBar extends StatelessWidget {
  final int activeIndex;
  final List<FrostedNavItem> items;
  final VoidCallback onPrimaryAction;
  final void Function(int) onTap;

  const FrostedNavBar({
    super.key,
    required this.activeIndex,
    required this.items,
    required this.onPrimaryAction,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          height: 60 + bottomInset,
          padding: EdgeInsets.only(bottom: bottomInset),
          decoration: const BoxDecoration(
            color: Color(0x99000000),
            border: Border(
              top: BorderSide(color: Color(0xFF2A2D33), width: 0.5),
            ),
          ),
          child: items.isEmpty
              ? const SizedBox.shrink()
              : Row(
                  children: _buildSlots(),
                ),
        ),
      ),
    );
  }

  List<Widget> _buildSlots() {
    final slots = <Widget>[];
    final centerSlot = items.length ~/ 2;
    final insertInCenter = items.length >= 4;

    for (var i = 0; i < items.length; i++) {
      if (insertInCenter && i == centerSlot) {
        slots.add(Expanded(child: _PrimaryActionButton(onTap: onPrimaryAction)));
      }
      slots.add(
        Expanded(
          child: _NavItemButton(
            item: items[i],
            active: i == activeIndex,
            onTap: () => onTap(i),
          ),
        ),
      );
    }
    if (!insertInCenter) {
      slots.add(Expanded(child: _PrimaryActionButton(onTap: onPrimaryAction)));
    }
    return slots;
  }
}

class _NavItemButton extends StatelessWidget {
  final FrostedNavItem item;
  final bool active;
  final VoidCallback onTap;

  const _NavItemButton({
    required this.item,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? LaqtaColors.accent : Colors.white54;
    return InkResponse(
      onTap: onTap,
      radius: 34,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(active ? item.activeIcon : item.icon, color: color, size: 22),
          const SizedBox(height: 2),
          Text(
            item.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: active ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: active ? LaqtaColors.accent : Colors.transparent,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  final VoidCallback onTap;

  const _PrimaryActionButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: LaqtaColors.accent,
            boxShadow: [
              BoxShadow(
                color: LaqtaColors.accent.withValues(alpha: 0.35),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.add_rounded, color: Color(0xFF0E1014)),
        ),
      ),
    );
  }
}
