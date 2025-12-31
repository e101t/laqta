import 'package:flutter/material.dart';
import 'package:luqta/core/constants/app_theme.dart';

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

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation ?? 2,
      color: color,
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
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
                          errorBuilder: (_, _, _) => _buildPlaceholder(),
                        )
                      : _buildPlaceholder(),
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
                      color: AppColors.cta,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, size: 14, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          'Top Rated',
                          style: AppTypography.caption.copyWith(
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
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      size: 20,
                      color: isFavorite ? Colors.red : AppColors.textSecondary,
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
                  style: AppTypography.h4,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(Icons.star, size: 16, color: AppColors.starFilled),
              const SizedBox(width: 4),
              Text(
                rating.toStringAsFixed(1),
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(' ($reviewsCount)', style: AppTypography.bodySmall),
            ],
          ),
          if (username != null && username!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              '@$username',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 4),

          // Governorate
          Row(
            children: [
              const Icon(
                Icons.location_on,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(governorate, style: AppTypography.bodySmall),
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
                    label: gender == 'female' ? 'أنثى' : 'ذكر',
                  ),
                if (age != null) _InfoChip(icon: Icons.cake, label: '$age سنة'),
              ],
            ),
          ],
          const SizedBox(height: 8),

          // Trust / availability badges
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              if (verified) _InfoChip(icon: Icons.shield, label: 'موثق'),
              if (pro) _InfoChip(icon: Icons.workspace_premium, label: 'محترف'),
              if (recommended)
                _InfoChip(icon: Icons.recommend, label: 'موصى به'),
              if (isNew) _InfoChip(icon: Icons.new_releases, label: 'جديد'),
              if (availableToday)
                _InfoChip(icon: Icons.bolt, label: 'متاح اليوم'),
              if (hasOffer)
                _InfoChip(
                  icon: Icons.local_offer,
                  label: offerLabel ?? 'عرض لقطة',
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
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  specialty,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.primary,
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
              Text('Starting from', style: AppTypography.bodySmall),
              const Spacer(),
              Text(
                '${basePrice.toStringAsFixed(0)} IQD',
                style: AppTypography.priceSmall,
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
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                  child: const Text('عرض الملف'),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: onFavorite,
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.divider,
      child: const Center(
        child: Icon(Icons.camera_alt, size: 48, color: AppColors.textSecondary),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(label, style: AppTypography.caption),
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
                      style: AppTypography.h4,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(type, style: AppTypography.bodySmall),
                  ],
                ),
              ),
              _buildStatusBadge(status),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.calendar_today,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(date, style: AppTypography.bodyMedium),
              const SizedBox(width: 16),
              const Icon(
                Icons.access_time,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(time, style: AppTypography.bodyMedium),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Total:',
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${price.toStringAsFixed(0)} IQD',
                style: AppTypography.priceSmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;

    switch (status) {
      case 'confirmed':
        color = AppColors.confirmed;
        text = 'Confirmed';
        break;
      case 'pending':
        color = AppColors.pending;
        text = 'Pending';
        break;
      case 'rejected':
        color = AppColors.rejected;
        text = 'Rejected';
        break;
      case 'done':
        color = AppColors.done;
        text = 'Done';
        break;
      case 'canceled':
        color = AppColors.canceled;
        text = 'Canceled';
        break;
      default:
        color = AppColors.textSecondary;
        text = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        text,
        style: AppTypography.caption.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
