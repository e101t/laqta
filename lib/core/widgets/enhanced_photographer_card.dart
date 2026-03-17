import 'package:flutter/material.dart';
import 'package:laqta/core/constants/app_animations.dart';
import 'package:laqta/core/localization/app_localizations.dart';

/// Enhanced Photographer Card with beautiful design and smooth animations
class EnhancedPhotographerCard extends StatefulWidget {
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
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final bool isFavorite;

  const EnhancedPhotographerCard({
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
    this.onTap,
    this.onFavorite,
    this.isFavorite = false,
  });

  @override
  State<EnhancedPhotographerCard> createState() =>
      _EnhancedPhotographerCardState();
}

class _EnhancedPhotographerCardState extends State<EnhancedPhotographerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.mediumDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: AppAnimations.easeOut),
    );

    _elevationAnimation = Tween<double>(begin: 4.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: AppAnimations.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            onTap: widget.onTap,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withValues(alpha: 0.08),
                    blurRadius: _elevationAnimation.value * 4,
                    offset: Offset(0, _elevationAnimation.value),
                    spreadRadius: _elevationAnimation.value / 2,
                  ),
                  BoxShadow(
                    color: colorScheme.shadow.withValues(alpha: 0.04),
                    blurRadius: _elevationAnimation.value * 2,
                    offset: Offset(0, _elevationAnimation.value / 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [_buildImageSection(), _buildInfoSection()],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageSection() {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    return Stack(
      children: [
        // Main Image with Gradient Overlay
        AspectRatio(
          aspectRatio: 16 / 10,
          child: Stack(
            fit: StackFit.expand,
            children: [
              widget.photoUrl != null
                  ? Image.network(
                      widget.photoUrl!,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return _buildImagePlaceholder();
                      },
                      errorBuilder: (_, _, _) => _buildImagePlaceholder(),
                    )
                  : _buildImagePlaceholder(),

              // Gradient Overlay for better text readability
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.3),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Top Rated Badge
        if (widget.isTopRated)
          Positioned(
            top: 12,
            left: 12,
            child: TweenAnimationBuilder<double>(
              duration: AppAnimations.longDuration,
              tween: Tween(begin: 0.0, end: 1.0),
              curve: AppAnimations.spring,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.stars, size: 16, color: Colors.white),
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
                );
              },
            ),
          ),

        // Favorite Button
        Positioned(
          top: 12,
          right: 12,
          child: TweenAnimationBuilder<double>(
            duration: AppAnimations.mediumDuration,
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Material(
                  color: colorScheme.surface.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(12),
                  elevation: 4,
                  child: InkWell(
                    onTap: widget.onFavorite,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: AnimatedSwitcher(
                        duration: AppAnimations.mediumDuration,
                        transitionBuilder: (child, animation) {
                          return ScaleTransition(
                            scale: animation,
                            child: child,
                          );
                        },
                        child: Icon(
                          widget.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          key: ValueKey(widget.isFavorite),
                          size: 24,
                          color: widget.isFavorite
                              ? colorScheme.error
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection() {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name and Rating
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.name,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.secondary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, size: 16, color: colorScheme.secondary),
                    const SizedBox(width: 4),
                    Text(
                      widget.rating.toStringAsFixed(1),
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Location and Reviews
          Row(
            children: [
              Icon(Icons.location_on, size: 14, color: colorScheme.primary),
              const SizedBox(width: 4),
              Text(
                widget.governorate,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${widget.reviewsCount} ${localizations.reviews}',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          if ((widget.username?.isNotEmpty ?? false) ||
              widget.gender != null ||
              widget.age != null) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                if (widget.username?.isNotEmpty ?? false)
                  _MiniChip(
                    icon: Icons.alternate_email,
                    label: '@${widget.username}',
                  ),
                if (widget.gender != null)
                  _MiniChip(
                    icon: widget.gender == 'female' ? Icons.female : Icons.male,
                    label: widget.gender == 'female'
                        ? localizations.female
                        : localizations.male,
                  ),
                if (widget.age != null)
                  _MiniChip(
                    icon: Icons.cake,
                    label: localizations.yearsOld(widget.age!),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 12),

          // Specialties Chips
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: widget.specialties.take(3).map((specialty) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primary.withValues(alpha: 0.15),
                      colorScheme.primary.withValues(alpha: 0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.3),
                    width: 1,
                  ),
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
          const SizedBox(height: 16),

          // Price and Book Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.startingFrom,
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${widget.basePrice.toStringAsFixed(0)} IQD',
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.secondary,
                      colorScheme.secondary.withValues(alpha: 0.9),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.secondary.withValues(alpha: 0.28),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.onTap,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      child: Text(
                        localizations.bookNow,
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      color: colorScheme.outlineVariant.withValues(alpha: 0.4),
      child: Center(
        child: Icon(
          Icons.camera_alt,
          size: 64,
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MiniChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
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
