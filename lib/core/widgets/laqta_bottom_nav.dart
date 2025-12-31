import 'package:flutter/material.dart';
import '../theme/laqta_tokens.dart';

class LAQTABottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<int?> badges;

  const LAQTABottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.badges = const [null, null, null, null],
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      destinations: [
        _buildDestination(
          label: 'الرئيسية',
          icon: Icons.home_outlined,
          selectedIcon: Icons.home,
          badge: badges[0],
        ),
        _buildDestination(
          label: 'بحث',
          icon: Icons.search_outlined,
          selectedIcon: Icons.search,
          badge: badges[1],
        ),
        _buildDestination(
          label: 'المحادثات',
          icon: Icons.chat_bubble_outline,
          selectedIcon: Icons.chat_bubble,
          badge: badges[2],
        ),
        _buildDestination(
          label: 'حسابي',
          icon: Icons.person_outline,
          selectedIcon: Icons.person,
          badge: badges[3],
        ),
      ],
    );
  }

  NavigationDestination _buildDestination({
    required String label,
    required IconData icon,
    required IconData selectedIcon,
    int? badge,
  }) {
    return NavigationDestination(
      label: label,
      icon: _iconWithBadge(icon, badge),
      selectedIcon: _iconWithBadge(selectedIcon, badge, isActive: true),
    );
  }

  Widget _iconWithBadge(IconData icon, int? badge, {bool isActive = false}) {
    if (badge == null || badge <= 0) {
      return Icon(icon);
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon),
        Positioned(
          right: -6,
          top: -6,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: LaqtaColors.error,
            ),
            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
            child: Text(
              badge > 9 ? '9+' : '$badge',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}
