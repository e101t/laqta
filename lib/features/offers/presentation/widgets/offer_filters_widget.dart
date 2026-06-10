import 'package:flutter/material.dart';

/// Offer Filters: Sort by Price, Trust Score, Delivery Time, Distance
class OfferFiltersWidget extends StatefulWidget {
  final Function(OfferFilterCriteria) onFilterChanged;
  final OfferFilterCriteria currentFilter;

  const OfferFiltersWidget({
    super.key,
    required this.onFilterChanged,
    required this.currentFilter,
  });

  @override
  State<OfferFiltersWidget> createState() => _OfferFiltersWidgetState();
}

class _OfferFiltersWidgetState extends State<OfferFiltersWidget> {
  late OfferFilterCriteria _selectedFilter;

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.currentFilter;
  }

  void _updateFilter(OfferFilterCriteria filter) {
    setState(() => _selectedFilter = filter);
    widget.onFilterChanged(filter);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _buildFilterChip(
            icon: '💰',
            label: 'السعر: الأقل أولاً',
            isSelected: _selectedFilter == OfferFilterCriteria.priceLowToHigh,
            onTap: () => _updateFilter(OfferFilterCriteria.priceLowToHigh),
          ),
          const SizedBox(width: 12),
          _buildFilterChip(
            icon: '⭐',
            label: 'الأعلى ثقة',
            isSelected: _selectedFilter == OfferFilterCriteria.trustScoreHigh,
            onTap: () => _updateFilter(OfferFilterCriteria.trustScoreHigh),
          ),
          const SizedBox(width: 12),
          _buildFilterChip(
            icon: '⏱️',
            label: 'التسليم الأسرع',
            isSelected: _selectedFilter == OfferFilterCriteria.deliveryFastest,
            onTap: () => _updateFilter(OfferFilterCriteria.deliveryFastest),
          ),
          const SizedBox(width: 12),
          _buildFilterChip(
            icon: '📍',
            label: 'الأقرب',
            isSelected: _selectedFilter == OfferFilterCriteria.distanceClosest,
            onTap: () => _updateFilter(OfferFilterCriteria.distanceClosest),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? scheme.primary : scheme.surface,
          border: Border.all(
            color: isSelected ? scheme.primary : scheme.outlineVariant,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(
              label,
              style: textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: isSelected ? scheme.onPrimary : scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Filter criteria enum
enum OfferFilterCriteria {
  priceLowToHigh,
  trustScoreHigh,
  deliveryFastest,
  distanceClosest,
}

/// Extension to describe filter
extension OfferFilterDescription on OfferFilterCriteria {
  String get description {
    switch (this) {
      case OfferFilterCriteria.priceLowToHigh:
        return 'السعر: الأقل إلى الأعلى';
      case OfferFilterCriteria.trustScoreHigh:
        return 'أعلى درجة ثقة';
      case OfferFilterCriteria.deliveryFastest:
        return 'أسرع تسليم';
      case OfferFilterCriteria.distanceClosest:
        return 'الأقرب إلى موقعك';
    }
  }

  /// Apply filter to list of offers
  List<OfferForSort> sortOffers(List<OfferForSort> offers) {
    final sorted = [...offers];
    switch (this) {
      case OfferFilterCriteria.priceLowToHigh:
        sorted.sort((a, b) => a.price.compareTo(b.price));
        break;
      case OfferFilterCriteria.trustScoreHigh:
        sorted.sort((a, b) => b.trustScore.compareTo(a.trustScore));
        break;
      case OfferFilterCriteria.deliveryFastest:
        sorted.sort((a, b) => a.deliveryDays.compareTo(b.deliveryDays));
        break;
      case OfferFilterCriteria.distanceClosest:
        sorted.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
        break;
    }
    return sorted;
  }
}

/// Model for offers that need sorting
class OfferForSort {
  final String offerId;
  final String photographerId;
  final double price;
  final double trustScore;
  final int deliveryDays;
  final double distanceKm;

  OfferForSort({
    required this.offerId,
    required this.photographerId,
    required this.price,
    required this.trustScore,
    required this.deliveryDays,
    required this.distanceKm,
  });
}
