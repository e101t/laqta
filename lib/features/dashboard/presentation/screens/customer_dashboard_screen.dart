import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:laqta/app/router/app_router.dart';
import 'package:laqta/core/constants/marketplace_assets.dart';
import 'package:laqta/core/services/backend_config.dart';
import 'package:laqta/core/widgets/laqta_async_widgets.dart';
import 'package:laqta/core/widgets/laqta_marketplace_widgets.dart';
import 'package:laqta/features/marketplace/domain/entities/marketplace_models.dart';
import 'package:laqta/features/marketplace/marketplace_dependencies.dart';
import 'package:laqta/features/marketplace/presentation/controllers/marketplace_controllers.dart';

class CustomerDashboardScreen extends StatelessWidget {
  const CustomerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          HomeFeedController(MarketplaceDependencies.repository)..load(),
      child: const _CustomerDashboardView(),
    );
  }
}

class _CustomerDashboardView extends StatefulWidget {
  const _CustomerDashboardView();

  @override
  State<_CustomerDashboardView> createState() => _CustomerDashboardViewState();
}

class _CustomerDashboardViewState extends State<_CustomerDashboardView> {
  final List<String> _tabs = const [
    'لك',
    'الأكثر مشاهدة',
    'زفاف',
    'جلسات',
    'نقاشات',
  ];
  int _selectedTab = 0;

  List<MarketplaceFeedEntry> _filterItems(List<MarketplaceFeedEntry> items) {
    final base = [...items];
    if (_selectedTab == 1) {
      base.sort((a, b) => b.rankingScore.compareTo(a.rankingScore));
      return base;
    }
    if (_selectedTab == 2) {
      return base
          .where(
            (item) =>
                item.kind == MarketplaceFeedKind.reel ||
                item.kind == MarketplaceFeedKind.photographer,
          )
          .toList(growable: false);
    }
    if (_selectedTab == 3) {
      return base
          .where((item) => item.kind != MarketplaceFeedKind.location)
          .toList(growable: false);
    }
    return base;
  }

  void _handleStoryTap(String id) {
    switch (id) {
      case 'venues':
        AppRouter.goToVenues(context);
        break;
      case 'locations':
        AppRouter.goToExplore(context);
        break;
      case 'photographers':
        AppRouter.goToExplore(context);
        break;
      default:
        AppRouter.goToExplore(context);
    }
  }

  void _openFeedItem(MarketplaceFeedEntry item) {
    switch (item.kind) {
      case MarketplaceFeedKind.venue:
        if (item.venue != null) {
          AppRouter.goToVenueDetails(context, item.venue!.id);
        }
        break;
      case MarketplaceFeedKind.location:
        if (item.venue != null) {
          AppRouter.goToLocationDetails(context, item.venue!.id);
        }
        break;
      case MarketplaceFeedKind.photographer:
        if (item.photographer != null) {
          AppRouter.goToPhotographerProfile(context, item.photographer!.id);
        }
        break;
      case MarketplaceFeedKind.reel:
        if (item.reel != null) {
          AppRouter.goToPhotographerProfile(context, item.reel!.photographerId);
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<HomeFeedController>();
    final feedItems = _filterItems(controller.items);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFF0E1014),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.load,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
            children: [
              Row(
                textDirection: TextDirection.ltr,
                children: [
                  Text(
                    'LAQTA',
                    style: textTheme.headlineSmall?.copyWith(
                      color: const Color(0xFFD6A44A),
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const Spacer(),
                  LaqtaTopIconButton(
                    icon: Icons.notifications_none_rounded,
                    badge: true,
                    onTap: () => AppRouter.goToNotifications(context),
                  ),
                  const SizedBox(width: 2),
                  LaqtaTopIconButton(
                    icon: Icons.chat_bubble_outline_rounded,
                    onTap: () => AppRouter.goToChatList(context),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              LaqtaLuxurySearchBar(
                hint: 'ابحث عن مصور، قاعة، مكان...',
                onTap: () => AppRouter.goToSearch(context),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 98,
                child: Builder(
                  builder: (context) {
                    final stories = MarketplaceAssets.storyShortcuts;
                    return Directionality(
                      textDirection: TextDirection.ltr,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: stories.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final story = stories[index];
                          return InkWell(
                            onTap: () => _handleStoryTap(story.id),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(2.2),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFFD6A44A),
                                      width: 1.3,
                                    ),
                                  ),
                                  child: CircleAvatar(
                                    radius: 26,
                                    backgroundImage: story.id == 'follow'
                                        ? null
                                        : AssetImage(story.imagePath),
                                    backgroundColor: const Color(0xFF17191F),
                                    child: story.id == 'follow'
                                        ? const Icon(
                                            Icons.add_rounded,
                                            color: Color(0xFFD6A44A),
                                            size: 28,
                                          )
                                        : null,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  story.title,
                                  style: textTheme.labelMedium?.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 32,
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _tabs.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 24),
                    itemBuilder: (context, index) {
                      final selected = _selectedTab == index;
                      return InkWell(
                        onTap: () => setState(() => _selectedTab = index),
                        child: Column(
                          children: [
                            Text(
                              _tabs[index],
                              style: textTheme.titleSmall?.copyWith(
                                color: selected
                                    ? const Color(0xFFD6A44A)
                                    : Colors.white70,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const Spacer(flex: 2),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: selected ? 28 : 0,
                              height: 2,
                              decoration: BoxDecoration(
                                color: const Color(0xFFD6A44A),
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 18),
              if (controller.isLoading && controller.items.isEmpty)
                ...List.generate(
                  3,
                  (_) => const Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: LaqtaSkeletonBox(
                      height: 320,
                      borderRadius: BorderRadius.all(Radius.circular(24)),
                    ),
                  ),
                )
              else if (feedItems.isEmpty && controller.error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: _DashboardStateMessage(message: controller.error!),
                )
              else if (feedItems.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: _DashboardStateMessage(
                    message: 'لا توجد منشورات بعد',
                    subtitle: 'ابدأ بمتابعة مصورين أو استكشف القاعات والأماكن',
                  ),
                )
              else
                ...feedItems.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _FeedCard(
                      item: item,
                      onTap: () => _openFeedItem(item),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardStateMessage extends StatelessWidget {
  final String message;
  final String? subtitle;

  const _DashboardStateMessage({required this.message, this.subtitle});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Column(
        children: [
          Text(
            message,
            style: textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              style: textTheme.bodyMedium?.copyWith(color: Colors.white60),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class _FeedCard extends StatelessWidget {
  final MarketplaceFeedEntry item;
  final VoidCallback onTap;

  const _FeedCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final imageUrl =
        item.reel?.mediaUrl ??
        item.venue?.coverUrl ??
        item.photographer?.photoUrl;
    final title =
        item.reel?.caption ??
        item.venue?.name ??
        item.photographer?.name ??
        'LAQTA';
    final creatorName =
        item.reel?.photographerName ??
        item.photographer?.name ??
        item.venue?.name ??
        'LAQTA';
    final likes =
        item.reel?.likes ??
        ((item.photographer?.ratingAverage ?? item.venue?.ratingAverage ?? 0) *
                100)
            .round();
    final comments =
        item.reel?.comments ??
        item.venue?.reviewCount ??
        item.photographer?.ratingCount ??
        0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: SizedBox(
              height: item.kind == MarketplaceFeedKind.photographer ? 290 : 220,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  LaqtaRemoteImage(
                    imageUrl: imageUrl,
                    fallbackAssetPath: switch (item.kind) {
                      MarketplaceFeedKind.photographer =>
                        MarketplaceAssets.heroPhotographer,
                      MarketplaceFeedKind.location =>
                        MarketplaceAssets.heroLocation,
                      MarketplaceFeedKind.venue => MarketplaceAssets.heroVenue,
                      MarketplaceFeedKind.reel => MarketplaceAssets.heroWedding,
                    },
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.08),
                          Colors.black.withValues(alpha: 0.68),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: AlignmentDirectional.topEnd,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (item.isSponsored || item.isFeatured)
                                Container(
                                  margin: const EdgeInsetsDirectional.only(
                                    end: 8,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD6A44A),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    item.isSponsored ? 'ممول' : 'مميز',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              const Icon(
                                Icons.more_vert_rounded,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Text(
                          title,
                          style: textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundImage: const AssetImage(
                                MarketplaceAssets.avatar,
                              ),
                              foregroundImage:
                                  BackendConfig.resolvePublicUrl(
                                        item.photographer?.photoUrl,
                                      ) !=
                                      null
                                  ? NetworkImage(
                                      BackendConfig.resolvePublicUrl(
                                        item.photographer?.photoUrl,
                                      )!,
                                    )
                                  : BackendConfig.resolvePublicUrl(
                                          item.reel?.photographerPhotoUrl,
                                        ) !=
                                        null
                                  ? NetworkImage(
                                      BackendConfig.resolvePublicUrl(
                                        item.reel?.photographerPhotoUrl,
                                      )!,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                creatorName,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: Colors.white70,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.mode_comment_outlined,
                size: 18,
                color: Colors.white70,
              ),
              const SizedBox(width: 4),
              Text(
                '$comments',
                style: textTheme.bodySmall?.copyWith(color: Colors.white70),
              ),
              const SizedBox(width: 14),
              const Icon(
                Icons.favorite_border_rounded,
                size: 18,
                color: Colors.white70,
              ),
              const SizedBox(width: 4),
              Text(
                likes >= 1000
                    ? '${(likes / 1000).toStringAsFixed(1)}K'
                    : '$likes',
                style: textTheme.bodySmall?.copyWith(color: Colors.white70),
              ),
              if (item.kind != MarketplaceFeedKind.photographer) ...[
                const Spacer(),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
