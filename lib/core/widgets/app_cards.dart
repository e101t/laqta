import 'package:flutter/material.dart';
import 'package:laqta/core/localization/app_localizations.dart';

/// Custom Card Widget
class AppCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? elevation;
  final Color? color;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.elevation,
    this.color,
  });

  BorderRadius _borderRadiusFrom(ShapeBorder? shape) {
    if (shape is RoundedRectangleBorder && shape.borderRadius is BorderRadius) {
      return shape.borderRadius as BorderRadius;
    }
    return BorderRadius.circular(16);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardTheme = theme.cardTheme;
    final shape = cardTheme.shape;
    final borderRadius = _borderRadiusFrom(shape);
    return Card(
      elevation: elevation ?? cardTheme.elevation ?? 2,
      color: color ?? cardTheme.color,
      shape: shape,
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}

/// Photographer Card Widget
class PhotographerCard extends StatelessWidget {
  final String photographerId;
  final String name;
  final String? photoUrl;
  final double rating;
  final int reviewsCount;
  final String governorate;
  final List<String> specialties;
  final double basePrice;
  final String? username;
  final String? gender;
  final int? age;
  final bool isTopRated;
  final bool verified;
  final bool pro;
  final bool recommended;
  final bool isNew;
  final bool availableToday;
  final bool hasOffer;
  final String? offerLabel;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final bool isFavorite;

  const PhotographerCard({
    super.key,
    required this.photographerId,
    required this.name,
    this.photoUrl,
    required this.rating,
    required this.reviewsCount,
    required this.governorate,
    required this.specialties,
    required this.basePrice,
    this.username,
    this.gender,
    this.age,
    this.isTopRated = false,
    this.verified = false,
    this.pro = false,
    this.recommended = false,
    this.isNew = false,
    this.availableToday = false,
    this.hasOffer = false,
    this.offerLabel,
    this.onTap,
    this.onFavorite,
    this.isFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image and Top Rated Badge
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: photoUrl != null
                      ? Image.network(
                          photoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _buildPlaceholder(context),
                        )
                      : _buildPlaceholder(context),
                ),
              ),
              if (isTopRated)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.secondary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, size: 14, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          localizations.topRated,
                          style: textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              // Favorite Button
              Positioned(
                top: 8,
                right: 8,
                child: InkWell(
                  onTap: onFavorite,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.surface.withValues(alpha: 0.92),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      size: 20,
                      color: isFavorite
                          ? colorScheme.error
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Name and Rating
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(Icons.star, size: 16, color: colorScheme.secondary),
              const SizedBox(width: 4),
              Text(
                rating.toStringAsFixed(1),
                style: textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(' ($reviewsCount)', style: textTheme.bodySmall),
            ],
          ),
          if (username != null && username!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              '@$username',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 4),

          // Governorate
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 14,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(governorate, style: textTheme.bodySmall),
            ],
          ),
          if (gender != null || age != null) ...[
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                if (gender != null)
                  _InfoChip(
                    icon: gender == 'female' ? Icons.female : Icons.male,
                    label: gender == 'female'
                        ? localizations.female
                        : localizations.male,
                  ),
                if (age != null)
                  _InfoChip(
                    icon: Icons.cake,
                    label: localizations.yearsOld(age!),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 8),

          // Trust / availability badges
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              if (verified)
                _InfoChip(icon: Icons.shield, label: localizations.verifiedBadge),
              if (pro)
                _InfoChip(icon: Icons.workspace_premium, label: localizations.proBadge),
              if (recommended)
                _InfoChip(
                  icon: Icons.recommend,
                  label: localizations.recommendedBadge,
                ),
              if (isNew)
                _InfoChip(icon: Icons.new_releases, label: localizations.newBadge),
              if (availableToday)
                _InfoChip(icon: Icons.bolt, label: localizations.availableTodayBadge),
              if (hasOffer)
                _InfoChip(
                  icon: Icons.local_offer,
                  label: offerLabel ?? localizations.offerBadge,
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Specialties
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: specialties.take(3).map((specialty) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  specialty,
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),

          // Price
          Row(
            children: [
              Text(localizations.startingFrom, style: textTheme.bodySmall),
              const Spacer(),
              Text(
                '${basePrice.toStringAsFixed(0)} IQD',
                style: textTheme.titleSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onTap,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.primary,
                    side: BorderSide(color: colorScheme.primary),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                  child: Text(localizations.viewProfile),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: onFavorite,
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite
                      ? colorScheme.error
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      color: scheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.camera_alt,
          size: 48,
          color: scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colorScheme.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(color: colorScheme.primary),
          ),
        ],
      ),
    );
  }
}

/// Booking Card Widget
class BookingCard extends StatelessWidget {
  final String bookingId;
  final String photographerName;
  final String? photographerPhoto;
  final String date;
  final String time;
  final String type;
  final String status;
  final double price;
  final VoidCallback? onTap;

  const BookingCard({
    super.key,
    required this.bookingId,
    required this.photographerName,
    this.photographerPhoto,
    required this.date,
    required this.time,
    required this.type,
    required this.status,
    required this.price,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: photographerPhoto != null
                    ? NetworkImage(photographerPhoto!)
                    : null,
                child: photographerPhoto == null
                    ? const Icon(Icons.person)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      photographerName,
                      style: textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(type, style: textTheme.bodySmall),
                  ],
                ),
              ),
              _buildStatusBadge(context, status),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 16,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(date, style: textTheme.bodyMedium),
              const SizedBox(width: 16),
              Icon(
                Icons.access_time,
                size: 16,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(time, style: textTheme.bodyMedium),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Total:',
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${price.toStringAsFixed(0)} IQD',
                style: textTheme.titleSmall?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, String status) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    Color color;
    String text;

    switch (status) {
      case 'confirmed':
        color = scheme.primary;
        text = 'Confirmed';
        break;
      case 'pending':
        color = scheme.secondary;
        text = 'Pending';
        break;
      case 'rejected':
        color = scheme.error;
        text = 'Rejected';
        break;
      case 'done':
        color = scheme.tertiary;
        text = 'Done';
        break;
      case 'canceled':
        color = scheme.outline;
        text = 'Canceled';
        break;
      default:
        color = scheme.onSurfaceVariant;
        text = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        text,
        style: textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
