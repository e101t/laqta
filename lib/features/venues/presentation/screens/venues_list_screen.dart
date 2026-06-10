import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:laqta/app/router/app_router.dart';
import 'package:laqta/core/constants/marketplace_assets.dart';
import 'package:laqta/core/theme/laqta_tokens.dart';
import 'package:laqta/core/widgets/laqta_async_widgets.dart';
import 'package:laqta/core/widgets/laqta_marketplace_widgets.dart';
import 'package:laqta/features/marketplace/marketplace_dependencies.dart';
import 'package:laqta/features/marketplace/presentation/controllers/marketplace_controllers.dart';

class VenuesListScreen extends StatelessWidget {
  const VenuesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          VenueCatalogueController(MarketplaceDependencies.repository)..load(),
      child: const _VenuesListView(),
    );
  }
}

class _VenuesListView extends StatelessWidget {
  const _VenuesListView();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<VenueCatalogueController>();
    final visibleItems = controller.filteredItems;
    final visibleCities = controller.cities;
    final selectedCity = controller.selectedCity;

    return Scaffold(
      backgroundColor: LaqtaColors.canvasDark,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.load,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                textDirection: TextDirection.ltr,
                children: [
                  const LaqtaHeaderBackButton(),
                  const Spacer(),
                  Text(
                    'القاعات',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  const LaqtaTopIconButton(icon: Icons.filter_alt_outlined),
                ],
              ),
              const SizedBox(height: 14),
              const LaqtaLuxurySearchBar(hint: 'ابحث عن قاعة زفاف'),
              const SizedBox(height: 16),
              SizedBox(
                height: 42,
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      final chip = visibleCities[index];
                      final selected = chip == selectedCity;
                      return LaqtaFilterPill(
                        label: chip,
                        selected: selected,
                        onTap: () => controller.setCity(chip),
                      );
                    },
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemCount: visibleCities.length,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (controller.isLoading && controller.items.isEmpty)
                ...List.generate(
                  4,
                  (_) => const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: LaqtaSkeletonBox(
                      height: 110,
                      borderRadius: BorderRadius.all(Radius.circular(22)),
                    ),
                  ),
                )
              else if (visibleItems.isEmpty && controller.error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      controller.error!,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                )
              else if (visibleItems.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'لا توجد قاعات حالياً',
                      style: TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                ...visibleItems.map(
                  (venue) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(22),
                      onTap: () =>
                          AppRouter.goToVenueDetails(context, venue.id),
                      child: LaqtaLuxurySurface(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          textDirection: TextDirection.ltr,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: LaqtaRemoteImage(
                                imageUrl: venue.coverUrl,
                                fallbackAssetPath: MarketplaceAssets.heroVenue,
                                width: 116,
                                height: 84,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    venue.name,
                                    textAlign: TextAlign.right,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${venue.city}${venue.area == null ? '' : ' - ${venue.area}'}',
                                    textAlign: TextAlign.right,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: const Color(0xFFB7B9BE),
                                        ),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      const Spacer(),
                                      Icon(
                                        Icons.star_rounded,
                                        size: 16,
                                        color: LaqtaColors.accent,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${venue.ratingAverage?.toStringAsFixed(1) ?? '0.0'} (${venue.reviewCount})',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(color: Colors.white),
                                      ),
                                      const SizedBox(width: 16),
                                      Text(
                                        _priceTier(
                                          venue.pricingFrom,
                                          venue.pricingTo,
                                        ),
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                              color: LaqtaColors.accent,
                                              fontWeight: FontWeight.w800,
                                            ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.favorite_border_rounded,
                              color: Colors.white70,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _priceTier(double? from, double? to) {
    final base = from ?? to;
    if (base == null) {
      return r'$$$';
    }
    if (base < 400) {
      return r'$$';
    }
    if (base < 900) {
      return r'$$$';
    }
    return r'$$$$';
  }
}
