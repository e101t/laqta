import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:laqta/app/router/app_router.dart';
import 'package:laqta/core/constants/marketplace_assets.dart';
import 'package:laqta/core/services/backend_config.dart';
import 'package:laqta/core/theme/laqta_tokens.dart';
import 'package:laqta/core/trust_safety/reporting_service.dart';
import 'package:laqta/core/widgets/laqta_async_widgets.dart';
import 'package:laqta/core/widgets/laqta_marketplace_widgets.dart';
import 'package:laqta/features/chat/chat_dependencies.dart';
import 'package:laqta/features/marketplace/domain/entities/marketplace_models.dart';
import 'package:laqta/features/marketplace/marketplace_dependencies.dart';
import 'package:laqta/features/marketplace/presentation/controllers/marketplace_controllers.dart';

class PhotographerProfileScreen extends StatelessWidget {
  final String photographerId;

  const PhotographerProfileScreen({super.key, required this.photographerId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PhotographerProfileController(
        MarketplaceDependencies.repository,
        photographerId,
      )..load(),
      child: const _PhotographerProfileView(),
    );
  }
}

class _PhotographerProfileView extends StatefulWidget {
  const _PhotographerProfileView();

  @override
  State<_PhotographerProfileView> createState() =>
      _PhotographerProfileViewState();
}

class _PhotographerProfileViewState extends State<_PhotographerProfileView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _openDirectChat(MarketplacePhotographerProfile profile) async {
    final messenger = ScaffoldMessenger.of(context);
    final result = await ChatDependencies.getOrCreateDirectChat().call(
      participantId: profile.id,
    );

    if (!mounted) return;
    final chat = result.valueOrNull;
    if (!result.isSuccess || chat == null) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('تعذر فتح المحادثة. يرجى المحاولة بعد الحجز.'),
        ),
      );
      return;
    }

    AppRouter.goToChat(context, chat.id, profile.name);
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PhotographerProfileController>();
    final loadedProfile = controller.profile;
    if (controller.isLoading && loadedProfile == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0E1014),
        bottomNavigationBar: LaqtaMarketplaceBottomNav(
          activeIndex: 4,
          onTap: (index) {
            switch (index) {
              case 0:
                AppRouter.goToHome(context);
                break;
              case 1:
                AppRouter.goToExplore(context);
                break;
              case 4:
                AppRouter.goToProfile(context);
                break;
              default:
                AppRouter.goToHome(context);
            }
          },
          onPrimaryAction: () => AppRouter.goToSponsoredAd(context),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (loadedProfile == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0E1014),
        bottomNavigationBar: LaqtaMarketplaceBottomNav(
          activeIndex: 4,
          onTap: (index) {
            switch (index) {
              case 0:
                AppRouter.goToHome(context);
                break;
              case 1:
                AppRouter.goToExplore(context);
                break;
              case 4:
                AppRouter.goToProfile(context);
                break;
              default:
                AppRouter.goToHome(context);
            }
          },
          onPrimaryAction: () => AppRouter.goToSponsoredAd(context),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              controller.error ?? 'تعذر تحميل ملف المصور.',
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final profile = loadedProfile;

    return Scaffold(
      backgroundColor: const Color(0xFF0E1014),
      bottomNavigationBar: LaqtaMarketplaceBottomNav(
        activeIndex: 4,
        onTap: (index) {
          switch (index) {
            case 0:
              AppRouter.goToHome(context);
              break;
            case 1:
              AppRouter.goToExplore(context);
              break;
            case 4:
              AppRouter.goToProfile(context);
              break;
            default:
              AppRouter.goToHome(context);
          }
        },
        onPrimaryAction: () => AppRouter.goToSponsoredAd(context),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: const Color(0xFF0E1014),
            foregroundColor: Colors.white,
            pinned: true,
            expandedHeight: 274,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  LaqtaRemoteImage(
                    imageUrl: profile.portfolio.isNotEmpty
                        ? profile.portfolio.first.url
                        : profile.photoUrl,
                    fallbackAssetPath: MarketplaceAssets.heroPhotographer,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                  const Positioned(
                    top: 18,
                    left: 18,
                    child: Icon(
                      Icons.chevron_left_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  Positioned(
                    top: 18,
                    right: 18,
                    child: IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(
                        Icons.more_vert_rounded,
                        color: Colors.white,
                      ),
                      onPressed: () => showReportContentSheet(
                        context: context,
                        targetType: 'user',
                        targetId: profile.id,
                        blockUserId: profile.id,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Transform.translate(
                offset: const Offset(0, -34),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.all(2.2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: LaqtaColors.accent,
                            width: 1.4,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 38,
                          backgroundImage: const AssetImage(
                            MarketplaceAssets.avatar,
                          ),
                          foregroundImage:
                              BackendConfig.resolvePublicUrl(
                                    profile.photoUrl,
                                  ) ==
                                  null
                              ? null
                              : NetworkImage(
                                  BackendConfig.resolvePublicUrl(
                                    profile.photoUrl,
                                  )!,
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      textDirection: TextDirection.ltr,
                      children: [
                        Text(
                          profile.name,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                        const SizedBox(width: 8),
                        if (profile.verified)
                          const Icon(
                            Icons.verified_rounded,
                            color: Color(0xFF3B82F6),
                            size: 22,
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      textDirection: TextDirection.ltr,
                      children: [
                        Text(
                          'مصور زفاف',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: Colors.white70),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          '|',
                          style: TextStyle(color: Colors.white38),
                        ),
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.location_on_outlined,
                          size: 18,
                          color: LaqtaColors.accent,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          profile.governorate ?? 'العراق',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          size: 18,
                          color: LaqtaColors.accent,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${profile.ratingAverage?.toStringAsFixed(1) ?? '0.0'} (${profile.ratingCount})',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    if ((profile.bio ?? '').isNotEmpty)
                      Text(
                        profile.bio!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                          height: 1.5,
                        ),
                      ),
                    const SizedBox(height: 18),
                    Row(
                      textDirection: TextDirection.ltr,
                      children: [
                        LaqtaMetricColumn(
                          value: '${profile.projectsCount}',
                          label: 'المشاريع',
                        ),
                        _divider(),
                        LaqtaMetricColumn(
                          value: _formatFollowers(profile.followersCount),
                          label: 'المتابعون',
                        ),
                        _divider(),
                        LaqtaMetricColumn(
                          value: '${profile.followingCount}',
                          label: 'متابع',
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      textDirection: TextDirection.ltr,
                      children: [
                        LaqtaPrimaryAction(
                          label: 'احجز الآن',
                          onTap: () => AppRouter.goToCreateRequest(context),
                        ),
                        const SizedBox(width: 12),
                        LaqtaPrimaryAction(
                          label: 'تواصل',
                          outlined: true,
                          onTap: () => _openDirectChat(profile),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      textDirection: TextDirection.ltr,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: _quickSections()
                          .map((item) => _quickCircle(item.$1, item.$2))
                          .toList(growable: false),
                    ),
                    const SizedBox(height: 18),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        labelColor: LaqtaColors.accent,
                        unselectedLabelColor: Colors.white54,
                        indicatorColor: LaqtaColors.accent,
                        tabs: const [
                          Tab(text: 'المتابعة'),
                          Tab(text: 'ريلز'),
                          Tab(text: 'المراجعات'),
                          Tab(text: 'الأعمال'),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 420,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _galleryGrid(profile.portfolio.take(3).toList()),
                          _reelsGrid(profile.reels),
                          _reviewsPreview(profile),
                          _galleryGrid(profile.portfolio),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() =>
      Container(width: 1, height: 36, color: const Color(0xFF292B31));

  String _formatFollowers(int value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return '$value';
  }

  List<(String, IconData)> _quickSections() {
    return const [
      ('تواصل', Icons.people_alt_outlined),
      ('جلسات', Icons.camera_alt_outlined),
      ('كواليس', Icons.workspaces_outline),
      ('استوديو', Icons.photo_camera_back_outlined),
    ];
  }

  Widget _quickCircle(String label, IconData icon) {
    return Column(
      children: [
        Container(
          width: 62,
          height: 62,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: LaqtaColors.accent.withValues(alpha: 0.75),
            ),
            color: const Color(0xFF17191F),
          ),
          child: Icon(icon, color: LaqtaColors.accent),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _galleryGrid(List<MarketplaceMediaAsset> gallery) {
    if (gallery.isEmpty) {
      return const Center(
        child: Text(
          'لا توجد أعمال معروضة بعد.',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.only(top: 18),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.78,
      ),
      itemCount: gallery.length,
      itemBuilder: (context, index) {
        const fallbackGallery = [
          'assets/images/marketplace/groom_portrait.png',
          MarketplaceAssets.heroSoft,
          'assets/images/marketplace/couple_portrait.png',
          MarketplaceAssets.heroWedding,
          MarketplaceAssets.heroVenue,
          MarketplaceAssets.heroLocation,
        ];
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: LaqtaRemoteImage(
            imageUrl: gallery[index].url,
            fallbackAssetPath: fallbackGallery[index % fallbackGallery.length],
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }

  Widget _reelsGrid(List<MarketplaceReelSummary> reels) {
    if (reels.isEmpty) {
      return const Center(
        child: Text(
          'لا توجد ريلز منشورة بعد.',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.only(top: 18),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.78,
      ),
      itemCount: reels.length,
      itemBuilder: (context, index) => ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            LaqtaRemoteImage(
              imageUrl: reels[index].mediaUrl,
              fallbackAssetPath: index.isEven
                  ? MarketplaceAssets.heroPhotographer
                  : MarketplaceAssets.heroWedding,
              fit: BoxFit.cover,
            ),
            PositionedDirectional(
              bottom: 8,
              end: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${reels[index].views}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _reviewsPreview(MarketplacePhotographerProfile profile) {
    return ListView(
      padding: const EdgeInsets.only(top: 18),
      children: [
        LaqtaLuxurySurface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ملخص التقييم',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    profile.ratingAverage?.toStringAsFixed(1) ?? '0.0',
                    style: const TextStyle(
                      color: LaqtaColors.accent,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'من ${profile.ratingCount} تقييمات موثقة، مع ${profile.projectsCount} مشاريع منفذة.',
                      style: const TextStyle(
                        color: Colors.white70,
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ...profile.specialties
            .take(3)
            .map(
              (specialty) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: LaqtaLuxurySurface(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          CircleAvatar(
                            radius: 18,
                            backgroundImage: AssetImage(
                              MarketplaceAssets.avatar,
                            ),
                          ),
                          SizedBox(width: 10),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        specialty,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: List.generate(
                          5,
                          (_) => const Icon(
                            Icons.star_rounded,
                            size: 16,
                            color: LaqtaColors.accent,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'تخصص موثّق ضمن ملف المصور الحالي مع جاهزية للحجز والترويج.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      ],
    );
  }
}
