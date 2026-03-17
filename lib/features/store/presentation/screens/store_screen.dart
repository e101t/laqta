import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:laqta/core/localization/app_localizations.dart';
import 'package:laqta/core/theme/laqta_tokens.dart';
import 'package:laqta/core/widgets/app_buttons.dart';
import 'package:laqta/core/widgets/empty_states.dart';
import 'package:laqta/features/requests/presentation/screens/create_request_screen.dart';

class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key});

  static const List<_StoreProduct> _demoProducts = [
    _StoreProduct(
      id: 'demo_product_1',
      title: 'Ø¥Ø·Ø§Ø± ØµÙˆØ± ÙØ§Ø®Ø±',
      subtitle: 'Ø®Ø´Ø¨ Ø·Ø¨ÙŠØ¹ÙŠ + Ø²Ø¬Ø§Ø¬ Ù…Ù‚Ø§ÙˆÙ… Ù„Ù„Ø®Ø¯Ø´',
      priceIQD: 35000,
      imageAssetPath: 'assets/images/offers/offer_1.png',
      badge: 'Ø¬Ø¯ÙŠØ¯',
    ),
    _StoreProduct(
      id: 'demo_product_2',
      title: 'Ø£Ù„Ø¨ÙˆÙ… Ù…Ø·Ø¨ÙˆØ¹',
      subtitle: 'ÙˆØ±Ù‚ Ø¹Ø§Ù„ÙŠ Ø§Ù„Ø¬ÙˆØ¯Ø© + ØªØµÙ…ÙŠÙ… Ø£Ù†ÙŠÙ‚',
      priceIQD: 65000,
      imageAssetPath: 'assets/images/offers/offer_2.png',
      badge: 'Ø§Ù„Ø£ÙƒØ«Ø± Ù…Ø¨ÙŠØ¹Ù‹Ø§',
    ),
    _StoreProduct(
      id: 'demo_product_3',
      title: 'Ø¬Ù„Ø³Ø© ØªØµÙˆÙŠØ± Ù…Ù†ØªØ¬Ø§Øª',
      subtitle: 'Ø¨Ø§Ù‚Ø© Ù…Ù†Ø§Ø³Ø¨Ø© Ù„Ù„Ù…ØªØ§Ø¬Ø± ÙˆØ§Ù„Ù…ØªØ§Ø¬Ø± Ø§Ù„Ø¥Ù„ÙƒØªØ±ÙˆÙ†ÙŠØ©',
      priceIQD: 120000,
      imageAssetPath: 'assets/images/offers/offer_3.png',
      badge: 'Ø¹Ø±Ø¶',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).toString();
    final products = _demoProducts;

    return Scaffold(
      appBar: AppBar(title: Text(localizations.shop)),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0.0, -0.65),
            radius: 1.25,
            colors: [
              LaqtaColors.accent.withValues(alpha: 0.12),
              scheme.surface,
            ],
          ),
        ),
        child: products.isEmpty
            ? EmptyState(
                icon: Icons.storefront_outlined,
                title: localizations.noProducts,
                message: localizations.productsEmptyMessage,
                emoji: 'ðŸ›ï¸',
              )
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _StoreHeroCard(
                    title: localizations.featuredProducts,
                    subtitle: 'Ù…Ù†ØªØ¬Ø§Øª Ù…Ø®ØªØ§Ø±Ø© Ø¨Ø¹Ù†Ø§ÙŠØ© Ù„ØªÙƒÙ…Ù„ ØªØ¬Ø±Ø¨Ø© Ø§Ù„ØªØµÙˆÙŠØ±.',
                    onTap: () => _showCatalogGuidanceSnackBar(context),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    localizations.featuredProducts,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: products.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.82,
                        ),
                    itemBuilder: (context, index) => _ProductCard(
                      product: products[index],
                      priceLabel: _formatIQD(products[index].priceIQD, locale),
                      onTap: () => _showProductBottomSheet(
                        context,
                        products[index],
                        locale,
                      ),
                      onOrder: () =>
                          _openProductInquiry(context, products[index], locale),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  static String _formatIQD(int amount, String locale) {
    final formatted = NumberFormat.decimalPattern(locale).format(amount);
    return '$formatted Ø¯.Ø¹';
  }

  static void _showCatalogGuidanceSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          Localizations.localeOf(context).languageCode == 'ar'
              ? 'Ø§Ø®ØªØ± Ù…Ù†ØªØ¬Ù‹Ø§ Ø«Ù… Ø£Ø±Ø³Ù„ Ø·Ù„Ø¨Ùƒ Ù…Ù† Ø¯Ø§Ø®Ù„ Ø§Ù„ØªØ·Ø¨ÙŠÙ‚.'
              : 'Choose a product, then send your request from inside the app.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static String _buildInquiryNotes(
    BuildContext context,
    _StoreProduct product,
    String locale,
  ) {
    final priceLabel = _formatIQD(product.priceIQD, locale);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    if (isArabic) {
      return '''Ù…Ù‡ØªÙ… Ø¨Ù‡Ø°Ø§ Ø§Ù„Ù…Ù†ØªØ¬ Ù…Ù† Ø§Ù„Ù…ØªØ¬Ø±:
Ø§Ù„Ø§Ø³Ù…: ${product.title}
Ø§Ù„ØªÙØ§ØµÙŠÙ„: ${product.subtitle}
Ø§Ù„Ø³Ø¹Ø±: $priceLabel
Ø£Ø­ØªØ§Ø¬ Ù…ØªØ§Ø¨Ø¹Ø© Ù„Ø¥ØªÙ…Ø§Ù… Ø§Ù„Ø·Ù„Ø¨.''';
    }
    return '''I am interested in this store item:
Name: ${product.title}
Details: ${product.subtitle}
Price: $priceLabel
Please contact me to complete the order.''';
  }

  static Future<void> _openProductInquiry(
    BuildContext context,
    _StoreProduct product,
    String locale,
  ) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CreateRequestScreen(
          prefillNotes: _buildInquiryNotes(context, product, locale),
        ),
      ),
    );
  }

  static void _showProductBottomSheet(
    BuildContext context,
    _StoreProduct product,
    String locale,
  ) {
    final parentContext = context;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (context) {
        final textTheme = Theme.of(context).textTheme;
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.title,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                product.subtitle,
                style: textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _formatIQD(product.priceIQD, locale),
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: LaqtaColors.accent,
                ),
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                text: AppLocalizations.of(context).orderNow,
                icon: Icons.shopping_bag_outlined,
                color: LaqtaColors.accent,
                onPressed: () {
                  Navigator.of(context).pop();
                  _openProductInquiry(parentContext, product, locale);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StoreHeroCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _StoreHeroCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: LaqtaGlass.blurSigma,
          sigmaY: LaqtaGlass.blurSigma,
        ),
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  scheme.surface.withValues(alpha: 0.72),
                  LaqtaColors.accent.withValues(alpha: 0.10),
                  scheme.surface.withValues(alpha: 0.55),
                ],
              ),
              border: Border.all(
                color: scheme.onSurface.withValues(alpha: 0.08),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        LaqtaColors.accent,
                        LaqtaColors.accent.withValues(alpha: 0.55),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.storefront_outlined,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: scheme.onSurface.withValues(alpha: 0.7),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final _StoreProduct product;
  final String priceLabel;
  final VoidCallback onTap;
  final VoidCallback onOrder;

  const _ProductCard({
    required this.product,
    required this.priceLabel,
    required this.onTap,
    required this.onOrder,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: scheme.onSurface.withValues(alpha: 0.08)),
            boxShadow: LaqtaShadows.soft,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(18),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          product.imageAssetPath,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    LaqtaColors.primary.withValues(alpha: 0.95),
                                    LaqtaColors.accent.withValues(alpha: 0.35),
                                  ],
                                ),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.photo_camera_outlined,
                                  color: Colors.white70,
                                  size: 36,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.55),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (product.badge != null)
                        PositionedDirectional(
                          top: 10,
                          start: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.55),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.12),
                              ),
                            ),
                            child: Text(
                              product.badge!,
                              style: textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      PositionedDirectional(
                        bottom: 10,
                        start: 10,
                        end: 10,
                        child: Text(
                          product.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.titleSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            priceLabel,
                            style: textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: LaqtaColors.accent,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: onOrder,
                          icon: const Icon(Icons.shopping_bag_outlined),
                          color: scheme.onSurface,
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints.tightFor(
                            width: 36,
                            height: 36,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: scheme.onSurface.withValues(
                              alpha: 0.06,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
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
    );
  }
}

class _StoreProduct {
  final String id;
  final String title;
  final String subtitle;
  final int priceIQD;
  final String imageAssetPath;
  final String? badge;

  const _StoreProduct({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.priceIQD,
    required this.imageAssetPath,
    this.badge,
  });
}
