import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:luqta/core/constants/app_theme.dart';
import 'package:luqta/core/localization/app_localizations.dart';
import 'package:luqta/core/utils/responsive.dart';
import 'package:luqta/features/home/presentation/screens/home_glass_screen.dart';
import 'package:luqta/screens/search/search_screen.dart';
import 'package:luqta/screens/chat/chat_list_screen.dart';
import 'package:luqta/screens/profile/profile_screen.dart';

class MainAppScreen extends StatefulWidget {
  const MainAppScreen({super.key});

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  int _currentIndex = 0;
  DateTime? _lastBackPress;

  final List<Widget> _screens = [
    const HomeGlassScreen(showBottomNav: false),
    const SearchScreen(),
    const ChatListScreen(),
    const ProfileScreen(),
  ];

  final List<BottomNavItem> _navItems = const [
    BottomNavItem(
      icon: FluentIcons.home_24_regular,
      activeIcon: FluentIcons.home_24_filled,
      label: 'الرئيسية',
    ),
    BottomNavItem(
      icon: FluentIcons.search_24_regular,
      activeIcon: FluentIcons.search_24_filled,
      label: 'بحث',
    ),
    BottomNavItem(
      icon: FluentIcons.chat_24_regular,
      activeIcon: FluentIcons.chat_24_filled,
      label: 'محادثات',
    ),
    BottomNavItem(
      icon: FluentIcons.person_24_regular,
      activeIcon: FluentIcons.person_24_filled,
      label: 'حسابي',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final isWideLayout = Responsive.isWideLayout(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        final navigator = Navigator.of(context);
        if (navigator.canPop()) {
          navigator.maybePop();
          return;
        }
        if (_currentIndex != 0) {
          setState(() => _currentIndex = 0);
          return;
        }
        final now = DateTime.now();
        if (_lastBackPress == null ||
            now.difference(_lastBackPress!) > const Duration(seconds: 2)) {
          _lastBackPress = now;
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(localizations.pressBackAgainToExit),
                duration: const Duration(seconds: 2),
              ),
            );
          return;
        }
        SystemNavigator.pop();
      },
      child: isWideLayout ? _buildWideLayout() : _buildNarrowLayout(),
    );
  }

  Widget _buildContent() {
    return IndexedStack(index: _currentIndex, children: _screens);
  }

  Widget _buildNarrowLayout() {
    return Scaffold(
      body: _buildContent(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildWideLayout() {
    final isExtended = Responsive.isDesktop(context);

    return Scaffold(
      body: Row(
        children: [
          SafeArea(
            child: NavigationRail(
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) =>
                  setState(() => _currentIndex = index),
              extended: isExtended,
              labelType: isExtended
                  ? NavigationRailLabelType.none
                  : NavigationRailLabelType.all,
              minWidth: 72,
              minExtendedWidth: 220,
              backgroundColor: AppColors.surface,
              destinations: _navItems.map((item) {
                return NavigationRailDestination(
                  icon: _buildRailIcon(item, false),
                  selectedIcon: _buildRailIcon(item, true),
                  label: Text(item.label),
                );
              }).toList(),
            ),
          ),
          const VerticalDivider(width: 1, thickness: 1),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          child: Row(
            children: List.generate(
              _navItems.length,
              (index) => Expanded(child: _buildNavItem(index)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final item = _navItems[index];
    final isActive = _currentIndex == index;

    return SizedBox(
      height: 50,
      child: GestureDetector(
        onTap: () => setState(() => _currentIndex = index),
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: double.infinity,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isActive
                ? Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    width: 1,
                  )
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isActive ? item.activeIcon : item.icon,
                color: isActive ? AppColors.primary : AppColors.textSecondary,
                size: isActive ? 26 : 24,
              ),
              if (item.badge != null && item.badge! > 0)
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 4),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [AppColors.error, Color(0xFFD32F2F)],
                      ),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 14,
                      minHeight: 14,
                    ),
                    child: Text(
                      item.badge! > 9 ? '9+' : '${item.badge}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRailIcon(BottomNavItem item, bool isActive) {
    final icon = Icon(
      isActive ? item.activeIcon : item.icon,
      color: isActive ? AppColors.primary : AppColors.textSecondary,
      size: 24,
    );

    if (item.badge == null || item.badge! <= 0) {
      return icon;
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        icon,
        Positioned(
          right: -6,
          top: -4,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.error, Color(0xFFD32F2F)],
              ),
            ),
            constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
            child: Text(
              item.badge! > 9 ? '9+' : '${item.badge}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}

class BottomNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int? badge;

  const BottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.badge,
  });
}
