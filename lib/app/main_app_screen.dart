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
import 'package:laqta/core/theme/laqta_tokens.dart';
import 'package:laqta/core/widgets/frosted_nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainAppScreen extends StatefulWidget {
  final Widget? exploreScreenOverride;

  const MainAppScreen({super.key, this.exploreScreenOverride});

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  static const int _centerActionIndex = 2;
  static const int _maxTabHistory = 12;
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
      if (!mounted) return;
      setState(() {
        _userRole = AppConstants.roleCustomer;
        _isLoadingRole = false;
      });
      return;
    }

    final cachedRole = await _readCachedRole(userId);
    if (mounted && cachedRole != null) {
      setState(() {
        _userRole = cachedRole;
        _isLoadingRole = false;
      });
    }

    String role = cachedRole ?? AppConstants.roleCustomer;
    try {
      final profileResult = await ProfileDependencies.getUserProfile()
          .call(userId: userId)
          .timeout(const Duration(seconds: 6));
      role = profileResult.valueOrNull?.role ?? role;
    } catch (_) {
      role = cachedRole ?? AppConstants.roleCustomer;
    }

    if (mounted) {
      final shouldResetTabs = _isLoadingRole || _userRole != role;
      setState(() {
        _userRole = role;
        _isLoadingRole = false;
        if (shouldResetTabs) {
          _currentIndex = 0;
          _tabHistory.clear();
          _loadedTabs
            ..clear()
            ..add(0);
          _screenCache.clear();
        }
      });
    }
  }

  Future<String?> _readCachedRole(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedUserId = prefs.getString(AppConstants.keyProfileCacheUserId);
      if (cachedUserId != userId) return null;
      final role = prefs.getString(AppConstants.keyProfileCacheRole)?.trim();
      return role == null || role.isEmpty ? null : role;
    } catch (_) {
      return null;
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
          label: AppLocalizations.current.home,
        ),
        BottomNavItem(
          icon: FluentIcons.compass_northwest_24_regular,
          activeIcon: FluentIcons.compass_northwest_24_filled,
          label: AppLocalizations.current.explore,
        ),
        BottomNavItem(
          icon: FluentIcons.add_24_regular,
          activeIcon: FluentIcons.add_24_filled,
          label: AppLocalizations.current.createLabel,
          isPrimaryAction: true,
        ),
        BottomNavItem(
          icon: FluentIcons.chat_24_regular,
          activeIcon: FluentIcons.chat_24_filled,
          label: AppLocalizations.current.messages,
        ),
        BottomNavItem(
          icon: FluentIcons.person_24_regular,
          activeIcon: FluentIcons.person_24_filled,
          label: AppLocalizations.current.profileTab,
        ),
      ];
    }

    return [
      BottomNavItem(
        icon: FluentIcons.home_24_regular,
        activeIcon: FluentIcons.home_24_filled,
        label: AppLocalizations.current.home,
      ),
      BottomNavItem(
        icon: FluentIcons.compass_northwest_24_regular,
        activeIcon: FluentIcons.compass_northwest_24_filled,
        label: AppLocalizations.current.explore,
      ),
      BottomNavItem(
        icon: FluentIcons.add_24_regular,
        activeIcon: FluentIcons.add_24_filled,
        label: AppLocalizations.current.createLabel,
        isPrimaryAction: true,
      ),
      BottomNavItem(
        icon: FluentIcons.chat_24_regular,
        activeIcon: FluentIcons.chat_24_filled,
        label: AppLocalizations.current.messages,
      ),
      BottomNavItem(
        icon: FluentIcons.person_24_regular,
        activeIcon: FluentIcons.person_24_filled,
        label: AppLocalizations.current.profileTab,
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
      if (_tabHistory.isEmpty || _tabHistory.last != _currentIndex) {
        _tabHistory.add(_currentIndex);
        if (_tabHistory.length > _maxTabHistory) {
          _tabHistory.removeAt(0);
        }
      }
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

    return Scaffold(
      backgroundColor: const Color(0xFF0E1014),
      body: Row(
        children: [
          _FrostedSideBar(
            currentIndex: _currentIndex,
            navItems: navItems,
            isExtended: isExtended,
            onSelect: _setTab,
            onPrimaryAction: () => _setTab(_centerActionIndex),
          ),
          Expanded(child: _buildContent(screenBuilders)),
        ],
      ),
    );
  }

  Widget _buildBottomNav(List<BottomNavItem> navItems) {
    final visibleItems = <FrostedNavItem>[];
    final visibleTabIndexes = <int>[];

    for (var index = 0; index < navItems.length; index++) {
      final item = navItems[index];
      if (item.isPrimaryAction) continue;
      visibleTabIndexes.add(index);
      visibleItems.add(
        FrostedNavItem(
          icon: item.icon,
          activeIcon: item.activeIcon,
          label: item.label,
        ),
      );
    }

    return Semantics(
      label: AppLocalizations.current.mainNavigationLabel,
      child: FrostedNavBar(
        activeIndex: visibleTabIndexes.indexOf(_currentIndex),
        items: visibleItems,
        onPrimaryAction: () => _setTab(_centerActionIndex),
        onTap: (index) => _setTab(visibleTabIndexes[index]),
      ),
    );
  }

  Future<void> _showCreateSheet() async {
    if (!mounted) return;
    final actions = _userRole == AppConstants.rolePhotographer
        ? [
            _CreateAction(
              title: AppLocalizations.current.newReel,
              icon: FluentIcons.video_24_regular,
              route: Routes.createPost,
            ),
            _CreateAction(
              title: AppLocalizations.current.newStory,
              icon: FluentIcons.flash_24_regular,
              route: Routes.createStory,
            ),
            _CreateAction(
              title: AppLocalizations.current.sponsoredAdTitle,
              icon: FluentIcons.megaphone_24_regular,
              route: Routes.sponsoredAd,
            ),
            _CreateAction(
              title: AppLocalizations.current.plansTitle,
              icon: FluentIcons.star_24_regular,
              route: Routes.subscriptionPlans,
            ),
          ]
        : [
            _CreateAction(
              title: AppLocalizations.current.newRequest,
              icon: FluentIcons.add_square_24_regular,
              route: Routes.requestCreate,
            ),
            _CreateAction(
              title: AppLocalizations.current.venuesTitle,
              icon: FluentIcons.building_24_regular,
              route: Routes.venues,
            ),
            _CreateAction(
              title: AppLocalizations.current.photoSpotsTitle,
              icon: FluentIcons.image_24_regular,
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
                AppLocalizations.current.whatToCreate,
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
                    child: Icon(action.icon, color: LaqtaColors.accent),
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

// ---------------------------------------------------------------------------
// Frosted sidebar — tablet / desktop replacement for NavigationRail
// ---------------------------------------------------------------------------

class _FrostedSideBar extends StatelessWidget {
  final int currentIndex;
  final List<BottomNavItem> navItems;
  final bool isExtended;
  final ValueChanged<int> onSelect;
  final VoidCallback onPrimaryAction;

  const _FrostedSideBar({
    required this.currentIndex,
    required this.navItems,
    required this.isExtended,
    required this.onSelect,
    required this.onPrimaryAction,
  });

  @override
  Widget build(BuildContext context) {
    final width = isExtended ? 200.0 : 72.0;

    return SafeArea(
      child: Container(
        width: width,
        decoration: const BoxDecoration(
          color: Color(0xFF0E1014),
          border: Border(
            left: BorderSide(
              color: Color(0xFF1E2028),
              width: 1,
            ),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Logo / brand mark
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: isExtended
                  ? Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        'لقطة',
                        style: TextStyle(
                          color: LaqtaColors.accent,
                          fontWeight: FontWeight.w900,
                          fontSize: 22,
                        ),
                      ),
                    )
                  : Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: LaqtaColors.accent.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Icon(
                        Icons.camera_rounded,
                        color: LaqtaColors.accent,
                        size: 18,
                      ),
                    ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: navItems.length,
                itemBuilder: (context, index) {
                  final item = navItems[index];
                  if (item.isPrimaryAction) {
                    return _SideBarPrimaryAction(
                      isExtended: isExtended,
                      onTap: onPrimaryAction,
                    );
                  }
                  final isActive = index == currentIndex;
                  return _SideBarItem(
                    item: item,
                    isActive: isActive,
                    isExtended: isExtended,
                    onTap: () => onSelect(index),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _SideBarItem extends StatelessWidget {
  final BottomNavItem item;
  final bool isActive;
  final bool isExtended;
  final VoidCallback onTap;

  const _SideBarItem({
    required this.item,
    required this.isActive,
    required this.isExtended,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: isActive
                ? LaqtaColors.accent.withValues(alpha: 0.10)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    isActive ? item.activeIcon : item.icon,
                    color: isActive ? LaqtaColors.accent : Colors.white38,
                    size: 22,
                  ),
                  if (item.badge != null && item.badge! > 0)
                    Positioned(
                      right: -5,
                      top: -4,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        child: Center(
                          child: Text(
                            item.badge! > 9 ? '9+' : '${item.badge}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 7,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              if (isExtended) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item.label,
                    style: TextStyle(
                      color: isActive ? LaqtaColors.accent : Colors.white54,
                      fontWeight:
                          isActive ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isActive)
                  Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: LaqtaColors.accent,
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SideBarPrimaryAction extends StatelessWidget {
  final bool isExtended;
  final VoidCallback onTap;

  const _SideBarPrimaryAction({
    required this.isExtended,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                LaqtaColors.accent,
                LaqtaColors.accent.withValues(alpha: 0.75),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: isExtended
                ? MainAxisAlignment.start
                : MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_rounded, color: Colors.black, size: 22),
              if (isExtended) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppLocalizations.current.createLabel,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
