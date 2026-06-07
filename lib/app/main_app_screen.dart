import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:laqta/app/router/routes.dart';
import 'package:laqta/core/constants/app_constants.dart';
import 'package:laqta/core/localization/app_localizations.dart';
import 'package:laqta/core/utils/responsive.dart';
import 'package:laqta/features/auth/auth_dependencies.dart';
import 'package:laqta/features/dashboard/presentation/screens/customer_dashboard_screen.dart';
import 'package:laqta/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:laqta/features/admin/presentation/screens/admin_disputes_screen.dart';
import 'package:laqta/features/admin/presentation/screens/admin_reports_screen.dart';
import 'package:laqta/features/admin/presentation/screens/admin_users_screen.dart';
import 'package:laqta/features/profile/profile_dependencies.dart';
import 'package:laqta/features/chat/presentation/screens/chat_list_screen.dart';
import 'package:laqta/features/profile/presentation/screens/profile_screen.dart';
import 'package:laqta/features/explore/presentation/screens/explore_screen.dart';

class MainAppScreen extends StatefulWidget {
  final Widget? exploreScreenOverride;

  const MainAppScreen({super.key, this.exploreScreenOverride});

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  static const int _centerActionIndex = 2;
  int _currentIndex = 0;
  String _userRole = '';
  bool _isLoadingRole = true;
  final List<int> _tabHistory = [];
  final Set<int> _loadedTabs = <int>{0};
  final Map<int, Widget> _screenCache = <int, Widget>{};
  DateTime? _lastBackPress;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _dismissTransientInput();
      }
    });
    _loadRole();
  }

  void _dismissTransientInput() {
    FocusManager.instance.primaryFocus?.unfocus();
    SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
  }

  Future<void> _loadRole() async {
    final authResult = await AuthDependencies.getCurrentUser().call();
    final userId = authResult.valueOrNull?.id;
    if (userId == null || userId.isEmpty) {
      setState(() {
        _userRole = AppConstants.roleCustomer;
        _isLoadingRole = false;
      });
      return;
    }

    final profileResult = await ProfileDependencies.getUserProfile().call(
      userId: userId,
    );
    final role = profileResult.valueOrNull?.role ?? AppConstants.roleCustomer;

    if (mounted) {
      setState(() {
        _userRole = role;
        _isLoadingRole = false;
        _currentIndex = 0;
        _tabHistory.clear();
        _loadedTabs
          ..clear()
          ..add(0);
        _screenCache.clear();
      });
    }
  }

  List<WidgetBuilder> _screenBuildersForRole() {
    Widget buildExploreScreen(BuildContext context) {
      return widget.exploreScreenOverride ?? const ExploreScreen();
    }

    if (_userRole == AppConstants.roleAdmin) {
      return [
        (context) => const AdminDashboardScreen(),
        (context) => const AdminDisputesScreen(),
        (context) => const AdminReportsScreen(),
        (context) => const AdminUsersScreen(),
        (context) => const ProfileScreen(),
      ];
    }
    if (_userRole == AppConstants.rolePhotographer) {
      return [
        (context) => const CustomerDashboardScreen(),
        buildExploreScreen,
        (context) => const SizedBox.shrink(),
        (context) => const ChatListScreen(),
        (context) => const ProfileScreen(),
      ];
    }
    return [
      (context) => const CustomerDashboardScreen(),
      buildExploreScreen,
      (context) => const SizedBox.shrink(),
      (context) => const ChatListScreen(),
      (context) => const ProfileScreen(),
    ];
  }

  List<BottomNavItem> _navItemsForRole(AppLocalizations localizations) {
    if (_userRole == AppConstants.roleAdmin) {
      return [
        BottomNavItem(
          icon: FluentIcons.grid_24_regular,
          activeIcon: FluentIcons.grid_24_filled,
          label: localizations.dashboard,
        ),
        BottomNavItem(
          icon: FluentIcons.alert_24_regular,
          activeIcon: FluentIcons.alert_24_filled,
          label: localizations.adminDisputes,
        ),
        BottomNavItem(
          icon: FluentIcons.flag_24_regular,
          activeIcon: FluentIcons.flag_24_filled,
          label: localizations.adminReports,
        ),
        BottomNavItem(
          icon: FluentIcons.people_24_regular,
          activeIcon: FluentIcons.people_24_filled,
          label: localizations.adminUsers,
        ),
        BottomNavItem(
          icon: FluentIcons.person_24_regular,
          activeIcon: FluentIcons.person_24_filled,
          label: localizations.accountSection,
        ),
      ];
    }
    if (_userRole == AppConstants.rolePhotographer) {
      return [
        BottomNavItem(
          icon: FluentIcons.home_24_regular,
          activeIcon: FluentIcons.home_24_filled,
          label: 'الرئيسية',
        ),
        BottomNavItem(
          icon: FluentIcons.compass_northwest_24_regular,
          activeIcon: FluentIcons.compass_northwest_24_filled,
          label: 'اكتشف',
        ),
        BottomNavItem(
          icon: FluentIcons.add_24_regular,
          activeIcon: FluentIcons.add_24_filled,
          label: 'إنشاء',
          isPrimaryAction: true,
        ),
        BottomNavItem(
          icon: FluentIcons.chat_24_regular,
          activeIcon: FluentIcons.chat_24_filled,
          label: 'الرسائل',
        ),
        BottomNavItem(
          icon: FluentIcons.person_24_regular,
          activeIcon: FluentIcons.person_24_filled,
          label: 'الملف الشخصي',
        ),
      ];
    }

    return [
      BottomNavItem(
        icon: FluentIcons.home_24_regular,
        activeIcon: FluentIcons.home_24_filled,
        label: 'الرئيسية',
      ),
      BottomNavItem(
        icon: FluentIcons.compass_northwest_24_regular,
        activeIcon: FluentIcons.compass_northwest_24_filled,
        label: 'اكتشف',
      ),
      BottomNavItem(
        icon: FluentIcons.add_24_regular,
        activeIcon: FluentIcons.add_24_filled,
        label: 'إنشاء',
        isPrimaryAction: true,
      ),
      BottomNavItem(
        icon: FluentIcons.chat_24_regular,
        activeIcon: FluentIcons.chat_24_filled,
        label: 'الرسائل',
      ),
      BottomNavItem(
        icon: FluentIcons.person_24_regular,
        activeIcon: FluentIcons.person_24_filled,
        label: 'الملف الشخصي',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final isWideLayout = Responsive.isWideLayout(context);
    final theme = Theme.of(context);

    if (_isLoadingRole) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final screenBuilders = _screenBuildersForRole();
    final navItems = _navItemsForRole(localizations);
    if (_currentIndex >= screenBuilders.length) {
      _currentIndex = 0;
    }

    final navigator = Navigator.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (navigator.canPop()) {
          navigator.pop();
          return;
        }
        if (_tabHistory.isNotEmpty) {
          final lastIndex = _tabHistory.removeLast();
          setState(() => _currentIndex = lastIndex);
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
      child: isWideLayout
          ? _buildWideLayout(screenBuilders, navItems)
          : _buildNarrowLayout(screenBuilders, navItems),
    );
  }

  void _setTab(int index) {
    _dismissTransientInput();
    if (_userRole != AppConstants.roleAdmin && index == _centerActionIndex) {
      _showCreateSheet();
      return;
    }
    if (index == _currentIndex) return;
    setState(() {
      _tabHistory.add(_currentIndex);
      _currentIndex = index;
      _loadedTabs.add(index);
    });
  }

  Widget _buildContent(List<WidgetBuilder> screenBuilders) {
    return IndexedStack(
      index: _currentIndex,
      children: List<Widget>.generate(screenBuilders.length, (index) {
        if (!_loadedTabs.contains(index)) {
          return const SizedBox.shrink();
        }
        return _screenCache.putIfAbsent(
          index,
          () => screenBuilders[index](context),
        );
      }),
    );
  }

  Widget _buildNarrowLayout(
    List<WidgetBuilder> screenBuilders,
    List<BottomNavItem> navItems,
  ) {
    return Scaffold(
      body: _buildContent(screenBuilders),
      bottomNavigationBar: _buildBottomNav(navItems),
    );
  }

  Widget _buildWideLayout(
    List<WidgetBuilder> screenBuilders,
    List<BottomNavItem> navItems,
  ) {
    final isExtended = Responsive.isDesktop(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Row(
        children: [
          SafeArea(
            child: NavigationRail(
              selectedIndex: _currentIndex,
              onDestinationSelected: _setTab,
              extended: isExtended,
              labelType: isExtended
                  ? NavigationRailLabelType.none
                  : NavigationRailLabelType.all,
              minWidth: 72,
              minExtendedWidth: 220,
              backgroundColor: colorScheme.surface,
              destinations: navItems.map((item) {
                return NavigationRailDestination(
                  icon: _buildRailIcon(item, false),
                  selectedIcon: _buildRailIcon(item, true),
                  label: Text(item.label),
                );
              }).toList(),
            ),
          ),
          const VerticalDivider(width: 1, thickness: 1),
          Expanded(child: _buildContent(screenBuilders)),
        ],
      ),
    );
  }

  Widget _buildBottomNav(List<BottomNavItem> navItems) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111317),
        border: Border(
          top: BorderSide(color: const Color(0xFF23262D), width: 1),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(
            textDirection: TextDirection.ltr,
            children: List.generate(
              navItems.length,
              (index) => Expanded(child: _buildNavItem(index, navItems)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, List<BottomNavItem> navItems) {
    final item = navItems[index];
    if (item.isPrimaryAction) {
      return _buildPrimaryActionNavItem(item);
    }
    final isActive = _currentIndex == index;
    final iconColor = isActive ? const Color(0xFFD6A44A) : Colors.white54;

    return SizedBox(
      height: 54,
      child: Semantics(
        button: true,
        selected: isActive,
        label: item.label,
        child: Tooltip(
          message: item.label,
          child: GestureDetector(
            onTap: () => _setTab(index),
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: double.infinity,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(
                        isActive ? item.activeIcon : item.icon,
                        color: iconColor,
                        size: isActive ? 23 : 22,
                      ),
                      if (item.badge != null && item.badge! > 0)
                        PositionedDirectional(
                          top: -5,
                          end: -8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.redAccent,
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
                                height: 1,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  SizedBox(
                    width: double.infinity,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        item.label,
                        maxLines: 1,
                        style: TextStyle(
                          color: iconColor,
                          fontSize: 9.0,
                          fontWeight: isActive
                              ? FontWeight.w800
                              : FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryActionNavItem(BottomNavItem item) {
    return SizedBox(
      height: 56,
      child: Center(
        child: GestureDetector(
          onTap: () => _setTab(_centerActionIndex),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFD6A44A),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD6A44A).withValues(alpha: 0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(Icons.add_rounded, color: Colors.black, size: 30),
          ),
        ),
      ),
    );
  }

  Widget _buildRailIcon(BottomNavItem item, bool isActive) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final icon = Icon(
      isActive ? item.activeIcon : item.icon,
      color: isActive ? colorScheme.primary : colorScheme.onSurfaceVariant,
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
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  colorScheme.error,
                  colorScheme.error.withValues(alpha: 0.85),
                ],
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

  Future<void> _showCreateSheet() async {
    if (!mounted) return;
    final actions = _userRole == AppConstants.rolePhotographer
        ? const [
            _CreateAction(
              title: 'ريل جديد',
              icon: Icons.ondemand_video_rounded,
              route: Routes.createPost,
            ),
            _CreateAction(
              title: 'ستوري جديدة',
              icon: Icons.bolt_outlined,
              route: Routes.createStory,
            ),
            _CreateAction(
              title: 'إعلان ممول',
              icon: Icons.campaign_outlined,
              route: Routes.sponsoredAd,
            ),
            _CreateAction(
              title: 'الباقات',
              icon: Icons.workspace_premium_outlined,
              route: Routes.subscriptionPlans,
            ),
          ]
        : const [
            _CreateAction(
              title: 'طلب جديد',
              icon: Icons.add_box_outlined,
              route: Routes.requestCreate,
            ),
            _CreateAction(
              title: 'القاعات',
              icon: Icons.chair_alt_outlined,
              route: Routes.venues,
            ),
            _CreateAction(
              title: 'أماكن التصوير',
              icon: Icons.landscape_outlined,
              route: '/locations/salam-garden',
            ),
          ];

    final selected = await showModalBottomSheet<_CreateAction>(
      context: context,
      backgroundColor: const Color(0xFF111317),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ماذا تريد أن تنشئ؟',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              ...actions.map(
                (action) => ListTile(
                  onTap: () => Navigator.of(context).pop(action),
                  leading: CircleAvatar(
                    backgroundColor: const Color(
                      0xFFD6A44A,
                    ).withValues(alpha: 0.15),
                    child: Icon(action.icon, color: const Color(0xFFD6A44A)),
                  ),
                  title: Text(
                    action.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (!mounted || selected == null) return;
    context.push(selected.route);
  }
}

class BottomNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int? badge;
  final bool isPrimaryAction;

  const BottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.badge,
    this.isPrimaryAction = false,
  });
}

class _CreateAction {
  final String title;
  final IconData icon;
  final String route;

  const _CreateAction({
    required this.title,
    required this.icon,
    required this.route,
  });
}
