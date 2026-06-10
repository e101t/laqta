import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';

import 'package:laqta/core/constants/marketplace_assets.dart';
import 'package:laqta/core/theme/laqta_tokens.dart';
import 'package:laqta/core/widgets/laqta_async_widgets.dart';
import 'package:laqta/core/widgets/laqta_marketplace_widgets.dart';
import 'package:laqta/features/marketplace/marketplace_dependencies.dart';
import 'package:laqta/features/marketplace/presentation/controllers/marketplace_controllers.dart';

class PhotoLocationDetailsScreen extends StatelessWidget {
  final String locationId;

  const PhotoLocationDetailsScreen({super.key, required this.locationId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VenueDetailsController(
        MarketplaceDependencies.repository,
        locationId,
        isLocation: true,
      )..load(),
      child: const _PhotoLocationDetailsView(),
    );
  }
}

class _PhotoLocationDetailsView extends StatelessWidget {
  const _PhotoLocationDetailsView();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<VenueDetailsController>();
    final loadedLocation = controller.venue;
    if (controller.isLoading && loadedLocation == null) {
      return const Scaffold(
        backgroundColor: LaqtaColors.canvasDark,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (loadedLocation == null) {
      return Scaffold(
        backgroundColor: LaqtaColors.canvasDark,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              controller.error ?? 'تعذر تحميل تفاصيل المكان.',
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final location = loadedLocation;

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
                    imageUrl: location.coverUrl,
                    fallbackAssetPath: MarketplaceAssets.heroLocation,
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
                    top: 56,
                    left: 16,
                    child: LaqtaHeroOverlayIconButton(
                      icon: Icons.chevron_left_rounded,
                    ),
                  ),
                  const Positioned(
                    top: 56,
                    right: 16,
                    child: LaqtaHeroOverlayIconButton(
                      icon: Icons.ios_share_rounded,
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
                        '${(location.media.isEmpty ? 1 : location.media.length)}/${(location.media.isEmpty ? 1 : location.media.length)}',
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
                    location.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 18,
                        color: LaqtaColors.accent,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          location.area == null
                              ? location.city
                              : '${location.city} - ${location.area}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
                      Icon(
                        Icons.star_rounded,
                        size: 18,
                        color: LaqtaColors.accent,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        location.ratingAverage?.toStringAsFixed(1) ?? '0.0',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: location.services
                        .take(4)
                        .map(
                          (item) => LaqtaFeaturePill(
                            icon: item.contains('طبيعة')
                                ? Icons.park_outlined
                                : item.contains('إضاءة')
                                ? Icons.wb_sunny_outlined
                                : item.contains('جلسات')
                                ? Icons.weekend_outlined
                                : Icons.camera_alt_outlined,
                            label: item,
                          ),
                        )
                        .toList(growable: false),
                  ),
                  const SizedBox(height: 22),
                  const LaqtaSectionHeader(title: 'وصف المكان'),
                  const SizedBox(height: 10),
                  LaqtaLuxurySurface(
                    child: Text(
                      location.description ?? 'لا يوجد وصف متاح حاليًا.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white70,
                        height: 1.7,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final lat = location.latitude;
                        final lng = location.longitude;
                        if (lat == null || lng == null) {
                          return;
                        }
                        final uri = Uri.parse(
                          'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
                        );
                        await launchUrl(
                          uri,
                          mode: LaunchMode.externalApplication,
                        );
                      },
                      icon: const Icon(Icons.location_on_outlined),
                      label: const Text('الموقع على الخريطة'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: LaqtaColors.accent,
                        elevation: 0,
                        side: const BorderSide(color: LaqtaColors.accent),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
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
