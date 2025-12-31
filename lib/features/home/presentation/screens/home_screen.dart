import 'package:flutter/material.dart';
import 'package:luqta/core/constants/app_theme.dart';
import 'package:luqta/core/constants/app_constants.dart';
import 'package:luqta/core/localization/app_localizations.dart';
import 'package:luqta/core/router/app_router.dart';
import 'package:luqta/core/utils/responsive.dart';
import 'package:luqta/core/widgets/app_cards.dart';
import 'package:luqta/core/widgets/loading_widgets.dart';
import 'package:luqta/core/widgets/story_widgets.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:logger/logger.dart';
import 'package:luqta/core/widgets/empty_states.dart';
import 'package:luqta/screens/chat/chat_list_screen.dart';
import 'package:luqta/features/auth/auth_dependencies.dart';
import 'package:luqta/features/home/domain/entities/home_photographer.dart';
import 'package:luqta/features/home/domain/entities/home_story.dart';
import 'package:luqta/features/home/home_dependencies.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Logger _logger = Logger();
  bool _isLoading = true;
  bool _isLoadingStories = true;
  String _currentUserId = '';
  String? _selectedGovernorate;
  String? _selectedSpecialty;
  String? _selectedGender; // NEW: Gender filter
  double _minRating = 0;
  bool _showFilters = false;
  String? _errorMessage;
  int _activeSection = 0;
  int _offersPage = 0;
  final PageController _offersController = PageController(
    viewportFraction: 0.9,
  );
  final List<String> _sectionLabels = [
    'موصى بهم',
    'الأعلى تقييمًا',
    'متاح اليوم',
  ];
  final List<Map<String, dynamic>> _quickFilters = const [
    {'label': 'موصى به ⭐', 'section': 0, 'icon': Icons.recommend},
    {
      'label': 'الأعلى تقييمًا 👍',
      'section': 1,
      'icon': Icons.star_rate_rounded,
    },
    {'label': 'متاح اليوم ⏱', 'section': 2, 'icon': Icons.flash_on},
    {'label': 'السعر الأقل 💰', 'section': 3, 'icon': Icons.price_change},
  ];
  final List<Map<String, dynamic>> _categories = const [
    {'label': 'مناسبات', 'icon': Icons.celebration},
    {'label': 'أعراس', 'icon': Icons.favorite},
    {'label': 'أطفال', 'icon': Icons.child_care},
    {'label': 'منتجات', 'icon': Icons.local_mall},
    {'label': 'شركات', 'icon': Icons.apartment},
  ];
  final List<Map<String, String>> _offers = [
    {
      'title': 'مصور الأسبوع ⭐',
      'subtitle': 'أعمال مميزة وأسعار خاصة',
      'image':
          'https://images.pexels.com/photos/167832/pexels-photo-167832.jpeg?auto=compress&cs=tinysrgb&w=1200',
    },
    {
      'title': 'خصم خاص 🔥',
      'subtitle': 'جلسة منتجات للشركات',
      'image':
          'https://images.pexels.com/photos/1668932/pexels-photo-1668932.jpeg?auto=compress&cs=tinysrgb&w=1200',
    },
    {
      'title': 'الأكثر طلبًا في بغداد 📍',
      'subtitle': 'حجوزات سريعة اليوم',
      'image':
          'https://images.pexels.com/photos/1494082/pexels-photo-1494082.jpeg?auto=compress&cs=tinysrgb&w=1200',
    },
  ];

  // Stories data
  final List<HomeStory> _stories = [];
  final List<HomePhotographer> _photographers = [];
  final Set<String> _followingPhotographers = {};

  @override
  void initState() {
    super.initState();
    _bootstrapUser();
    _loadStories();
    _loadPhotographers();
  }

  Future<void> _bootstrapUser() async {
    await _loadCurrentUser();
    await _loadFollowing();
  }

  Future<void> _loadCurrentUser() async {
    final result = await AuthDependencies.getCurrentUser().call();
    if (!mounted) return;
    setState(() {
      _currentUserId = result.valueOrNull?.id ?? '';
    });
  }

  Future<void> _loadStories() async {
    setState(() => _isLoadingStories = true);

    try {
      final result = await HomeDependencies.getActiveStories().call();
      if (!result.isSuccess) {
        throw StateError(
          result.failureOrNull?.message ?? 'Failed to load stories',
        );
      }
      final stories = result.valueOrNull ?? <HomeStory>[];

      if (!mounted) return;
      setState(() {
        _stories
          ..clear()
          ..addAll(stories);
        _isLoadingStories = false;
      });
    } catch (e) {
      _logger.e('Error loading stories: $e');
      if (!mounted) return;
      setState(() => _isLoadingStories = false);
    }
  }

  Future<void> _loadFollowing() async {
    final userId = _currentUserId;
    if (userId.isEmpty) return;

    try {
      final result = await HomeDependencies.getFollowingIds().call(
        userId: userId,
      );
      if (!result.isSuccess) {
        throw StateError(
          result.failureOrNull?.message ?? 'Failed to load following',
        );
      }
      final ids = result.valueOrNull ?? <String>{};
      if (!mounted) return;
      setState(() {
        _followingPhotographers
          ..clear()
          ..addAll(ids);
      });
    } catch (e) {
      _logger.e('Error loading following: $e');
    }
  }

  Future<void> _loadPhotographers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await HomeDependencies.getHomePhotographers().call(
        governorate: _selectedGovernorate,
        specialty: _selectedSpecialty,
        gender: _selectedGender,
        minRating: _minRating,
      );
      if (!result.isSuccess) {
        throw StateError(
          result.failureOrNull?.message ?? 'Failed to load photographers',
        );
      }
      final results = result.valueOrNull ?? <HomePhotographer>[];

      if (!mounted) return;
      setState(() {
        _photographers
          ..clear()
          ..addAll(results);
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      _logger.e(
        'Error loading photographers',
        error: e,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'تعذر تحميل المصورين. اسحب للتحديث ثم حاول مرة أخرى.';
      });
    }
  }

  void _followPhotographer(String photographerId) async {
    final userId = _currentUserId;
    if (userId.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الرجاء تسجيل الدخول لمتابعة المصورين')),
        );
      }
      return;
    }

    final isFollowing = _followingPhotographers.contains(photographerId);

    setState(() {
      if (isFollowing) {
        _followingPhotographers.remove(photographerId);
      } else {
        _followingPhotographers.add(photographerId);
      }
    });

    try {
      final result = await HomeDependencies.setFollowStatus().call(
        followerId: userId,
        targetId: photographerId,
        follow: !isFollowing,
      );
      if (!result.isSuccess) {
        throw StateError(
          result.failureOrNull?.message ?? 'Failed to update follow status',
        );
      }
    } catch (e) {
      _logger.e('Error updating follow status: $e');
      // Revert the UI change on error
      setState(() {
        if (isFollowing) {
          _followingPhotographers.add(photographerId);
        } else {
          _followingPhotographers.remove(photographerId);
        }
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر تحديث حالة المتابعة')),
        );
      }
    }
  }

  void _viewStory(List<HomeStory> photographerStories, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StoryViewerScreen(
          stories: photographerStories,
          initialIndex: index,
          currentUserId: _currentUserId,
          onStoryViewed: (storyId) async {
            try {
              final result = await HomeDependencies.recordStoryView().call(
                storyId: storyId,
                userId: _currentUserId,
              );
              if (!result.isSuccess) {
                throw StateError(
                  result.failureOrNull?.message ??
                      'Failed to record story view',
                );
              }
            } catch (e) {
              _logger.e('Error marking story as viewed: $e');
            }
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _offersController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    const animDuration = Duration(milliseconds: 260);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await _loadStories();
            await _loadPhotographers();
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeroHeader(localizations, animDuration),

                    // Offers Carousel
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 4),
                      child: _buildOffersCarousel(),
                    ),

                    // Photographer of the week
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildTopPhotographerBanner(),
                    ),

                    // Quick filters row
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: _buildQuickFiltersRow(),
                    ),

                    // Categories row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: _buildCategoriesRow(),
                    ),

                    // Section Tabs
                    _buildSectionTabs(),

                    // Stories Section
                    AnimatedSwitcher(
                      duration: animDuration,
                      child: _isLoadingStories
                          ? Container(
                              key: const ValueKey('stories-loading'),
                              height: 110,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : _buildStoriesStrip(),
                    ),

                    // Nearby photographers
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: _buildNearbySection(),
                    ),

                    // Active Filters Chips
                    AnimatedSwitcher(
                      duration: animDuration,
                      transitionBuilder: (child, animation) => SizeTransition(
                        sizeFactor: animation,
                        axisAlignment: -1,
                        child: FadeTransition(opacity: animation, child: child),
                      ),
                      child: _hasActiveFilters()
                          ? _buildActiveFiltersChips()
                          : const SizedBox(),
                    ),
                  ],
                ),
              ),

              // Photographers List
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                sliver: SliverToBoxAdapter(
                  child: _buildPhotographersSection(
                    localizations,
                    _filterBySection(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroHeader(
    AppLocalizations localizations,
    Duration animDuration,
  ) {
    final isWide = Responsive.isWideLayout(context);

    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/images/hero_main.png',
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Colors.black.withValues(alpha: 0.1),
                  AppColors.primary.withValues(alpha: 0.6),
                  AppColors.cta.withValues(alpha: 0.85),
                ],
              ),
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(18, 18, 18, isWide ? 28 : 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 24,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localizations.appName,
                          style: AppTypography.h4.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          localizations.explorePhotographers,
                          style: AppTypography.bodySmall.copyWith(
                            color: Colors.white.withValues(alpha: 0.92),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _headerIcon(
                    icon: FluentIcons.alert_24_regular,
                    size: 20,
                    onTap: () => AppRouter.goToNotifications(context),
                  ),
                  const SizedBox(width: 8),
                  _headerIcon(
                    icon: FluentIcons.chat_24_regular,
                    size: 22,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ChatListScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _headerIcon(
                          icon: FluentIcons.search_24_regular,
                          onTap: () => AppRouter.goToSearch(context),
                        ),
                        const Spacer(),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: IconButton(
                            icon: Icon(
                              FluentIcons.filter_24_regular,
                              color: AppColors.textPrimary,
                              size: 22,
                            ),
                            onPressed: () {
                              if (Responsive.isWideLayout(context)) {
                                setState(() => _showFilters = !_showFilters);
                              } else {
                                _openAdvancedFilters();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    if (_showFilters)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: _buildFiltersPanel(),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _headerIcon({
    required IconData icon,
    required VoidCallback onTap,
    double size = 24,
  }) {
    return Container(
      width: 46,
      height: 46,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        padding: const EdgeInsets.all(10),
        constraints: const BoxConstraints(),
        icon: Icon(icon, color: AppColors.primary, size: size),
        onPressed: onTap,
      ),
    );
  }

  Future<void> _openAdvancedFilters() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, controller) {
            return SafeArea(
              top: false,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: SingleChildScrollView(
                  controller: controller,
                  child: _buildFiltersPanel(inBottomSheet: true),
                ),
              ),
            );
          },
        );
      },
    );
  }

  List<HomePhotographer> _filterBySection() {
    final list = List<HomePhotographer>.from(_photographers);
    if (_activeSection == 1) {
      list.sort((a, b) => (b.rating).compareTo(a.rating));
    } else if (_activeSection == 3) {
      list.sort((a, b) => (a.basePrice).compareTo(b.basePrice));
    }
    // Placeholder for "متاح اليوم" until availability data is added
    return list;
  }

  Widget _buildOffersCarousel() {
    return SizedBox(
      height: 180,
      child: PageView.builder(
        controller: _offersController,
        onPageChanged: (i) => setState(() => _offersPage = i),
        itemCount: _offers.length,
        itemBuilder: (context, index) {
          final offer = _offers[index];
          final active = _offersPage == index;
          return AnimatedScale(
            scale: active ? 1.02 : 0.98,
            duration: const Duration(milliseconds: 200),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: NetworkImage(offer['image']!),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withValues(alpha: 0.28),
                    BlendMode.darken,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 18,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          offer['title'] ?? '',
                          style: AppTypography.h3.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          offer['subtitle'] ?? '',
                          style: AppTypography.bodyMedium.copyWith(
                            color: Colors.white.withValues(alpha: 0.92),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {},
                          child: const Text('شاهد'),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 16,
                    child: Row(
                      children: List.generate(
                        _offers.length,
                        (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          height: 6,
                          width: active && i == index ? 18 : 6,
                          decoration: BoxDecoration(
                            color: i == _offersPage
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopPhotographerBanner() {
    final top = _pickPhotographerOfWeek();
    if (top == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundImage: top.photoUrl != null
                ? NetworkImage(top.photoUrl!)
                : null,
            child: top.photoUrl == null
                ? const Icon(Icons.camera_alt, color: AppColors.primary)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('مصور الأسبوع', style: AppTypography.bodySmall),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.verified,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  top.displayName,
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '⭐ ${top.rating.toStringAsFixed(1)} • ${top.reviewsCount} مراجعة',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => AppRouter.goToPhotographerProfile(context, top.id),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('شاهد'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickFiltersRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _quickFilters.map((item) {
          final selected = _activeSection == item['section'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    item['icon'] as IconData,
                    size: 16,
                    color: selected ? AppColors.primary : AppColors.textPrimary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    item['label'] as String,
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              selected: selected,
              onSelected: (_) {
                setState(() => _activeSection = item['section'] as int);
              },
              selectedColor: AppColors.primary.withValues(alpha: 0.12),
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: selected ? AppColors.primary : AppColors.divider,
                ),
              ),
              labelStyle: TextStyle(
                color: selected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategoriesRow() {
    return SizedBox(
      height: 72,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemBuilder: (context, index) {
          final item = _categories[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Column(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    item['icon'] as IconData,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item['label'] as String,
                  style: AppTypography.bodySmall.copyWith(fontSize: 12),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNearbySection() {
    if (_photographers.isEmpty) return const SizedBox.shrink();
    // For now: use top-rated as a proxy for "قريب منك"
    final nearby = List<HomePhotographer>.from(_photographers)
      ..sort((a, b) => b.rating.compareTo(a.rating));
    final subset = nearby.take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.near_me, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              'مصورون قريبون منك الآن',
              style: AppTypography.h4.copyWith(fontSize: 16),
            ),
            const Spacer(),
            TextButton(
              onPressed: _openAdvancedFilters,
              child: const Text('تصفية'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: subset.length,
            itemBuilder: (context, index) {
              final p = subset[index];
              return Container(
                width: 240,
                margin: EdgeInsets.only(right: index == 0 ? 8 : 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundImage: p.photoUrl != null
                              ? NetworkImage(p.photoUrl!)
                              : null,
                          child: p.photoUrl == null
                              ? const Icon(
                                  Icons.camera_alt,
                                  color: AppColors.primary,
                                )
                              : null,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p.displayName,
                                style: AppTypography.bodyLarge.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                p.primaryGovernorate.isNotEmpty
                                    ? p.primaryGovernorate
                                    : 'قريب منك',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '⭐ ${p.rating.toStringAsFixed(1)}',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      p.specialties.join(' • '),
                      style: AppTypography.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () =>
                            AppRouter.goToPhotographerProfile(context, p.id),
                        icon: const Icon(Icons.visibility),
                        label: const Text('عرض الملف'),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  HomePhotographer? _pickPhotographerOfWeek() {
    if (_photographers.isEmpty) return null;
    final sorted = List<HomePhotographer>.from(_photographers)
      ..sort((a, b) => b.rating.compareTo(a.rating));
    return sorted.first;
  }

  Widget _buildSectionTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: List.generate(_sectionLabels.length, (index) {
          final selected = _activeSection == index;
          return Padding(
            padding: EdgeInsets.only(right: index == 0 ? 0 : 8),
            child: ChoiceChip(
              label: Text(
                _sectionLabels[index],
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              selected: selected,
              selectedColor: AppColors.primary.withValues(alpha: 0.12),
              backgroundColor: AppColors.surface,
              onSelected: (_) => setState(() => _activeSection = index),
              labelStyle: TextStyle(
                color: selected ? AppColors.primary : AppColors.textPrimary,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: selected ? AppColors.primary : AppColors.divider,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPhotographersSection(
    AppLocalizations localizations,
    List<HomePhotographer> data,
  ) {
    if (_isLoading) {
      return Column(
        children: List.generate(
          3,
          (index) => const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: PhotographerCardSkeleton(),
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: ErrorState(
          title: localizations.error,
          message: _errorMessage,
          onRetry: _loadPhotographers,
        ),
      );
    }

    if (data.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
        child: EmptyState(
          icon: Icons.camera_alt_outlined,
          title: localizations.noPhotographers,
          message:
              'حاول تغيير الفلاتر أو سحب للتحديث لاكتشاف المزيد من المصورين.',
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final profile = data[index];
        return Padding(
          padding: EdgeInsets.only(bottom: index == data.length - 1 ? 0 : 16),
          child: _buildPhotographerCard(profile, localizations),
        );
      },
    );
  }

  Widget _buildPhotographerCard(
    HomePhotographer profile,
    AppLocalizations localizations,
  ) {
    final isTop = profile.isTopRated || profile.rating >= 4.7;
    final isNew = profile.reviewsCount < 5;
    final hasOffer = profile.basePrice < 50000; // معيار مبدئي لعرض
    final availableToday = _activeSection == 2;
    final governorate = profile.primaryGovernorate.isNotEmpty
        ? profile.primaryGovernorate
        : localizations.governorate;

    return PhotographerCard(
      photographerId: profile.id,
      name: profile.displayName,
      photoUrl: profile.photoUrl,
      rating: profile.rating,
      reviewsCount: profile.reviewsCount,
      governorate: governorate,
      specialties: profile.specialties,
      basePrice: profile.basePrice,
      username: profile.username,
      gender: profile.gender,
      age: profile.age,
      isTopRated: isTop,
      verified: profile.isTopRated,
      pro: profile.rating >= 4.5,
      recommended: isTop,
      isNew: isNew,
      availableToday: availableToday,
      hasOffer: hasOffer,
      offerLabel: hasOffer ? 'عرض لقطة' : null,
      isFavorite: _followingPhotographers.contains(profile.id),
      onFavorite: () => _followPhotographer(profile.id),
      onTap: () => AppRouter.goToPhotographerProfile(context, profile.id),
    );
  }

  Widget _buildStoriesStrip() {
    final followedStories = _getUniquePhotographers();
    if (_stories.isEmpty || followedStories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      key: const ValueKey('stories-list'),
      height: 110,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.divider, width: 1)),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: followedStories.length,
        itemBuilder: (context, index) {
          final photographer = followedStories[index];
          final photographerStories = _stories
              .where((s) => s.photographerId == photographer['id'])
              .toList();
          final hasNewStory = photographerStories.any(
            (s) => !s.hasUserViewed(_currentUserId),
          );

          return StoryCircle(
            photographerId: photographer['id'] as String,
            photographerName: photographer['name'] as String,
            photographerPhotoUrl: photographer['photoUrl'] as String?,
            hasNewStory: hasNewStory,
            isFollowing: _followingPhotographers.contains(photographer['id']),
            onTap: () => _viewStory(photographerStories, 0),
            onFollowTap: () =>
                _followPhotographer(photographer['id'] as String),
          );
        },
      ),
    );
  }

  List<Map<String, dynamic>> _getUniquePhotographers() {
    final photographersMap = <String, Map<String, dynamic>>{};

    for (final story in _stories) {
      if (!_followingPhotographers.contains(story.photographerId)) continue;
      photographersMap.putIfAbsent(story.photographerId, () {
        return {
          'id': story.photographerId,
          'name': story.photographerName,
          'photoUrl': story.photographerPhotoUrl,
        };
      });
    }

    return photographersMap.values.toList();
  }

  Future<void> _applyFilters({required bool closePanel}) async {
    if (closePanel) {
      final navigator = Navigator.of(context);
      if (navigator.canPop()) {
        navigator.pop();
      }
    } else if (_showFilters) {
      setState(() => _showFilters = false);
    }
    await _loadPhotographers();
  }

  Widget _buildFiltersPanel({bool inBottomSheet = false}) {
    InputDecoration decor(String label, IconData icon) => InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: AppColors.surface,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.primary, width: 1.3),
      ),
    );

    final isWide = Responsive.isWideLayout(context);
    final maxWidth = isWide ? 720.0 : double.infinity;

    final governorateField = DropdownButtonFormField<String>(
      isDense: true,
      itemHeight: 52,
      initialValue: _selectedGovernorate,
      decoration: decor('المحافظة 📍', FluentIcons.location_24_regular),
      items: AppConstants.iraqiGovernoratesAr.map((gov) {
        return DropdownMenuItem(value: gov, child: Text(gov));
      }).toList(),
      onChanged: (value) {
        setState(() => _selectedGovernorate = value);
      },
    );

    final specialtyField = DropdownButtonFormField<String>(
      isDense: true,
      itemHeight: 52,
      initialValue: _selectedSpecialty,
      decoration: decor('نوع التصوير 🎞️', FluentIcons.grid_24_regular),
      items: AppConstants.specialtiesAr.map((spec) {
        return DropdownMenuItem(value: spec, child: Text(spec));
      }).toList(),
      onChanged: (value) {
        setState(() => _selectedSpecialty = value);
      },
    );

    final genderField = DropdownButtonFormField<String>(
      isDense: true,
      itemHeight: 52,
      initialValue: _selectedGender,
      decoration: decor('الجنس', FluentIcons.person_24_regular),
      items: const [
        DropdownMenuItem(value: 'male', child: Text('ذكر 🔹')),
        DropdownMenuItem(value: 'female', child: Text('أنثى 🔸')),
      ],
      onChanged: (value) {
        setState(() => _selectedGender = value);
      },
    );

    final ratingField = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              FluentIcons.star_24_filled,
              color: AppColors.cta,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'التقييم: ${_minRating.toStringAsFixed(1)}+',
              style: AppTypography.bodyMedium,
            ),
          ],
        ),
        Slider(
          value: _minRating,
          min: 0,
          max: 5,
          divisions: 10,
          label: _minRating.toStringAsFixed(1),
          onChanged: (value) {
            setState(() => _minRating = value);
          },
        ),
      ],
    );

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('الفلاتر 🎯', style: AppTypography.h4),
              const SizedBox(height: 12),
              if (isWide)
                Row(
                  children: [
                    Expanded(child: governorateField),
                    const SizedBox(width: 12),
                    Expanded(child: specialtyField),
                  ],
                )
              else ...[
                governorateField,
                const SizedBox(height: 12),
                specialtyField,
              ],
              const SizedBox(height: 12),
              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: genderField),
                    const SizedBox(width: 12),
                    Expanded(child: ratingField),
                  ],
                )
              else ...[
                genderField,
                const SizedBox(height: 12),
                ratingField,
              ],
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedGovernorate = null;
                          _selectedSpecialty = null;
                          _selectedGender = null;
                          _minRating = 0;
                        });
                        _loadPhotographers();
                      },
                      child: const Text('إعادة تعيين المرشحات'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _isLoading
                          ? null
                          : () => _applyFilters(closePanel: inBottomSheet),
                      child: _isLoading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('تطبيق'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _hasActiveFilters() {
    return _selectedGovernorate != null ||
        _selectedSpecialty != null ||
        _selectedGender != null ||
        _minRating > 0;
  }

  Widget _buildActiveFiltersChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            if (_selectedGovernorate != null)
              _buildFilterChip(
                _selectedGovernorate!,
                () => setState(() => _selectedGovernorate = null),
              ),
            if (_selectedSpecialty != null)
              _buildFilterChip(
                _selectedSpecialty!,
                () => setState(() => _selectedSpecialty = null),
              ),
            if (_selectedGender != null)
              _buildFilterChip(
                _selectedGender == 'male' ? 'ذكر' : 'أنثى',
                () => setState(() => _selectedGender = null),
              ),
            if (_minRating > 0)
              _buildFilterChip(
                '⭐ ${_minRating.toStringAsFixed(1)}+',
                () => setState(() => _minRating = 0),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onRemove) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(label),
        onDeleted: onRemove,
        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
        deleteIconColor: AppColors.primary,
      ),
    );
  }
}
