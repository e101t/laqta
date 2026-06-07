import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:laqta/app/router/app_router.dart';
import 'package:laqta/core/constants/marketplace_assets.dart';
import 'package:laqta/core/theme/laqta_tokens.dart';
import 'package:laqta/core/trust_safety/reporting_service.dart';
import 'package:laqta/core/widgets/laqta_async_widgets.dart';
import 'package:laqta/core/widgets/laqta_marketplace_widgets.dart';
import 'package:laqta/features/marketplace/marketplace_dependencies.dart';
import 'package:laqta/features/marketplace/presentation/controllers/marketplace_controllers.dart';

class VenueDetailsScreen extends StatelessWidget {
  final String venueId;

  const VenueDetailsScreen({super.key, required this.venueId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          VenueDetailsController(MarketplaceDependencies.repository, venueId)
            ..load(),
      child: const _VenueDetailsView(),
    );
  }
}

class _VenueDetailsView extends StatelessWidget {
  const _VenueDetailsView();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<VenueDetailsController>();
    final loadedVenue = controller.venue;
    if (controller.isLoading && loadedVenue == null) {
      return const Scaffold(
        backgroundColor: LaqtaColors.canvasDark,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (loadedVenue == null) {
      return Scaffold(
        backgroundColor: LaqtaColors.canvasDark,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              controller.error ?? 'تعذر تحميل تفاصيل القاعة.',
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final venue = loadedVenue;

    return Scaffold(
      backgroundColor: LaqtaColors.canvasDark,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: LaqtaColors.canvasDark,
            foregroundColor: Colors.white,
            pinned: true,
            expandedHeight: 320,
            automaticallyImplyLeading: false,
            leadingWidth: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
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
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.72),
                        ],
                      ),
                    ),
                  ),
                  const Positioned(
                    top: 56,
                    left: 16,
                    child: LaqtaHeroOverlayIconButton(
                      icon: Icons.chevron_left_rounded,
                    ),
                  ),
                  Positioned(
                    top: 56,
                    right: 16,
                    child: Row(
                      children: [
                        const LaqtaHeroOverlayIconButton(
                          icon: Icons.favorite_border_rounded,
                        ),
                        const SizedBox(width: 10),
                        const LaqtaHeroOverlayIconButton(
                          icon: Icons.ios_share_rounded,
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () => showReportContentSheet(
                            context: context,
                            targetType: 'venue',
                            targetId: venue.id,
                          ),
                          child: const LaqtaHeroOverlayIconButton(
                            icon: Icons.report_gmailerrorred_outlined,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PositionedDirectional(
                    bottom: 16,
                    end: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${(venue.media.isEmpty ? 1 : venue.media.length)}/${(venue.media.isEmpty ? 1 : venue.media.length)}',
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
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    venue.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.star_rounded,
                        size: 18,
                        color: LaqtaColors.accent,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${venue.ratingAverage?.toStringAsFixed(1) ?? '0.0'} (${venue.reviewCount})',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.location_on_outlined,
                        size: 18,
                        color: LaqtaColors.accent,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${venue.city}${venue.area == null ? '' : ' - ${venue.area}'}',
                          style: const TextStyle(color: Colors.white70),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      if (venue.capacityMin != null ||
                          venue.capacityMax != null)
                        LaqtaFeaturePill(
                          icon: Icons.groups_2_outlined,
                          label:
                              '${venue.capacityMin ?? 0}-${venue.capacityMax ?? 0} السعة',
                        ),
                      ...venue.services
                          .take(3)
                          .map(
                            (item) => LaqtaFeaturePill(
                              icon: item.contains('موقف')
                                  ? Icons.local_parking_outlined
                                  : item.contains('بوفيه')
                                  ? Icons.restaurant_outlined
                                  : Icons.chair_alt_outlined,
                              label: item,
                            ),
                          ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  const LaqtaSectionHeader(title: 'نبذة عن القاعة'),
                  const SizedBox(height: 10),
                  LaqtaLuxurySurface(
                    child: Text(
                      venue.description ?? 'لا يوجد وصف متاح حاليًا.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white70,
                        height: 1.7,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (venue.availability.isNotEmpty) ...[
                    const LaqtaSectionHeader(title: 'التوفر القادم'),
                    const SizedBox(height: 10),
                    LaqtaLuxurySurface(
                      child: Column(
                        children: venue.availability
                            .take(5)
                            .map(
                              (slot) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${slot.date.year}/${slot.date.month}/${slot.date.day}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      slot.status,
                                      style: const TextStyle(
                                        color: LaqtaColors.accent,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(growable: false),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  Row(
                    textDirection: TextDirection.ltr,
                    children: [
                      LaqtaPrimaryAction(
                        label: 'احجز الآن',
                        onTap: () =>
                            AppRouter.goToVenueBooking(context, venue.id),
                      ),
                      const SizedBox(width: 12),
                      LaqtaPrimaryAction(
                        label: 'مراسلة',
                        outlined: true,
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
