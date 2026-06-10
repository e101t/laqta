import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:laqta/app/router/app_router.dart';
import 'package:laqta/core/constants/marketplace_assets.dart';
import 'package:laqta/core/theme/laqta_tokens.dart';
import 'package:laqta/core/widgets/laqta_async_widgets.dart';
import 'package:laqta/core/widgets/laqta_marketplace_widgets.dart';
import 'package:laqta/features/marketplace/marketplace_dependencies.dart';
import 'package:laqta/features/marketplace/domain/entities/marketplace_models.dart';
import 'package:laqta/features/marketplace/presentation/controllers/marketplace_controllers.dart';

class ExploreScreen extends StatefulWidget {
  final dynamic followService;
  final dynamic reportService;
  final Future<Set<String>> Function(String userId)? fetchFollowingOverride;
  final Future<void> Function({
    required String reporterId,
    required String targetId,
    required String targetType,
    required String targetOwnerId,
    required String reason,
  })?
  submitReportOverride;

  const ExploreScreen({
    super.key,
    this.followService,
    this.reportService,
    this.fetchFollowingOverride,
    this.submitReportOverride,
  });

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          ExploreMarketplaceController(MarketplaceDependencies.repository)
            ..load(),
      child: const _ExploreMarketplaceView(),
    );
  }
}

class _ExploreMarketplaceView extends StatelessWidget {
  const _ExploreMarketplaceView();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ExploreMarketplaceController>();
    final data = controller.data;
    final featuredVenues = data?.featuredVenues ?? const <MarketplaceVenue>[];
    final nearbyPlaces = data?.nearbyPlaces ?? const <MarketplaceVenue>[];
    final recommendedCreators =
        data?.recommendedCreators ?? const <MarketplacePhotographerSummary>[];
    final hasAnyResults =
        featuredVenues.isNotEmpty ||
        nearbyPlaces.isNotEmpty ||
        recommendedCreators.isNotEmpty ||
        (data?.trendingPhotographers.isNotEmpty ?? false) ||
        (data?.trendingReels.isNotEmpty ?? false);

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
                  const LaqtaHeaderBackButton(),
                  const Spacer(),
                  Text(
                    'اكتشف',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 36),
                ],
              ),
              const SizedBox(height: 14),
              LaqtaLuxurySearchBar(
                hint: 'ابحث عن مصور، قاعة، مكان...',
                onTap: () => AppRouter.goToSearch(context),
              ),
              const SizedBox(height: 18),
              Row(
                textDirection: TextDirection.ltr,
                children: [
                  Expanded(
                    child: _CategoryCard(
                      title: 'المصورون',
                      icon: Icons.camera_alt_outlined,
                      onTap: () => AppRouter.goToExplore(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _CategoryCard(
                      title: 'القاعات',
                      icon: Icons.location_city_outlined,
                      onTap: () => AppRouter.goToVenues(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _CategoryCard(
                      title: 'أماكن التصوير',
                      icon: Icons.landscape_outlined,
                      onTap: () {
                        final first = nearbyPlaces.firstOrNull;
                        if (first != null) {
                          AppRouter.goToLocationDetails(context, first.id);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (controller.isLoading && data == null)
                const LaqtaSkeletonBox(
                  height: 230,
                  borderRadius: BorderRadius.all(Radius.circular(24)),
                )
              else if (controller.error != null && data == null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: _ExploreStateMessage(message: controller.error!),
                )
              else if (!hasAnyResults)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: _ExploreStateMessage(
                    message: 'لا توجد نتائج حالياً',
                    subtitle: 'جرّب تحديث الصفحة أو البحث بكلمة مختلفة',
                  ),
                )
              else if (featuredVenues.isNotEmpty) ...[
                LaqtaSectionHeader(
                  title: 'القاعات المميزة',
                  action: 'عرض الكل',
                  onAction: () => AppRouter.goToVenues(context),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 232,
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: ListView.separated(
                      key: const ValueKey('featured-venues-scroll'),
                      scrollDirection: Axis.horizontal,
                      itemCount: featuredVenues.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 12),
                      itemBuilder: (context, index) => SizedBox(
                        width: 300,
                        child: _FeaturedVenueCard(venue: featuredVenues[index]),
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              const LaqtaSectionHeader(
                title: 'أماكن تصوير مميزة',
                action: 'عرض الكل',
              ),
              const SizedBox(height: 12),
              if (controller.isLoading && data == null)
                SizedBox(
                  height: 192,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: 3,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (context, index) => const LaqtaSkeletonBox(
                      width: 178,
                      height: 192,
                      borderRadius: BorderRadius.all(Radius.circular(22)),
                    ),
                  ),
                )
              else if (nearbyPlaces.isEmpty && hasAnyResults)
                const _ExploreStateMessage(
                  message: 'لا توجد أماكن تصوير حالياً',
                )
              else
                SizedBox(
                  height: 192,
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: ListView.separated(
                      key: const ValueKey('featured-locations-scroll'),
                      scrollDirection: Axis.horizontal,
                      itemCount: nearbyPlaces.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final location = nearbyPlaces[index];
                        return InkWell(
                          onTap: () => AppRouter.goToLocationDetails(
                            context,
                            location.id,
                          ),
                          borderRadius: BorderRadius.circular(22),
                          child: SizedBox(
                            width: 146,
                            child: LaqtaLuxurySurface(
                              padding: const EdgeInsets.all(10),
                              radius: 22,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: LaqtaRemoteImage(
                                      imageUrl: location.coverUrl,
                                      fallbackAssetPath:
                                          MarketplaceAssets.heroLocation,
                                      height: 92,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    location.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on_outlined,
                                        color: LaqtaColors.accent,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 2),
                                      Expanded(
                                        child: Text(
                                          location.city,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(color: Colors.white60),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              if (recommendedCreators.isNotEmpty) ...[
                const SizedBox(height: 24),
                const LaqtaSectionHeader(
                  title: 'المبدعون المقترحون',
                  action: 'عرض الكل',
                ),
                const SizedBox(height: 12),
                ...recommendedCreators.map(
                  (creator) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () => AppRouter.goToPhotographerProfile(
                        context,
                        creator.id,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      child: LaqtaLuxurySurface(
                        padding: const EdgeInsets.all(12),
                        radius: 20,
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: const Color(0xFF1C1E23),
                              backgroundImage: const AssetImage(
                                MarketplaceAssets.avatar,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    creator.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    creator.governorate ?? 'العراق',
                                    style: const TextStyle(
                                      color: Colors.white60,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: LaqtaColors.accent,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
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

class _CategoryCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 96,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF17191F), Color(0xFF13151A)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF2A2D33)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: LaqtaColors.accent),
            const SizedBox(height: 10),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _FeaturedVenueCard extends StatelessWidget {
  final MarketplaceVenue venue;

  const _FeaturedVenueCard({required this.venue});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => AppRouter.goToVenueDetails(context, venue.id),
      borderRadius: BorderRadius.circular(24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: SizedBox(
          height: 230,
          child: Stack(
            fit: StackFit.expand,
            children: [
              LaqtaRemoteImage(
                imageUrl: venue.coverUrl,
                fallbackAssetPath: MarketplaceAssets.heroVenue,
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.08),
                      Colors.black.withValues(alpha: 0.62),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: AlignmentDirectional.topEnd,
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.35),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.favorite_border_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      venue.name,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: Color(0xFFD6A44A),
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          venue.area == null
                              ? venue.city
                              : '${venue.city} - ${venue.area}',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.white70),
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
    );
  }
}

class _ExploreStateMessage extends StatelessWidget {
  final String message;
  final String? subtitle;

  const _ExploreStateMessage({required this.message, this.subtitle});

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

extension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
