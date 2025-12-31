import 'package:flutter/material.dart';
import 'package:luqta/core/constants/app_theme.dart';

/// Shimmer effect for skeleton loaders
class ShimmerLoading extends StatefulWidget {
  final Widget child;

  const ShimmerLoading({super.key, required this.child});

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [
                (_animation.value - 1).clamp(0.0, 1.0),
                _animation.value.clamp(0.0, 1.0),
                (_animation.value + 1).clamp(0.0, 1.0),
              ],
              colors: const [
                Color(0xFFEBEBF4),
                Color(0xFFF4F4F4),
                Color(0xFFEBEBF4),
              ],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

/// Skeleton box for loading placeholders
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const SkeletonBox({super.key, this.width, this.height, this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.divider,
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
    );
  }
}

/// Skeleton for photographer card
class SkeletonPhotographerCard extends StatelessWidget {
  const SkeletonPhotographerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            const SkeletonBox(
              width: double.infinity,
              height: 200,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  const SkeletonBox(width: 150, height: 20),
                  const SizedBox(height: 8),

                  // Location
                  const SkeletonBox(width: 100, height: 14),
                  const SizedBox(height: 12),

                  // Specialties
                  Row(
                    children: [
                      const SkeletonBox(width: 80, height: 28),
                      const SizedBox(width: 8),
                      const SkeletonBox(width: 80, height: 28),
                      const SizedBox(width: 8),
                      const SkeletonBox(width: 60, height: 28),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Price and button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SkeletonBox(width: 100, height: 40),
                      SkeletonBox(
                        width: 120,
                        height: 40,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton for booking card
class SkeletonBookingCard extends StatelessWidget {
  const SkeletonBookingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const SkeletonBox(width: 60, height: 60),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SkeletonBox(width: double.infinity, height: 16),
                  const SizedBox(height: 8),
                  const SkeletonBox(width: 120, height: 14),
                  const SizedBox(height: 8),
                  const SkeletonBox(width: 80, height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton for story circle
class SkeletonStoryCircle extends StatelessWidget {
  const SkeletonStoryCircle({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: const BoxDecoration(
              color: AppColors.divider,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 8),
          const SkeletonBox(width: 60, height: 12),
        ],
      ),
    );
  }
}

/// Skeleton for chat message
class SkeletonChatMessage extends StatelessWidget {
  final bool isSender;

  const SkeletonChatMessage({super.key, this.isSender = false});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Align(
        alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          padding: const EdgeInsets.all(12),
          constraints: const BoxConstraints(maxWidth: 250),
          decoration: BoxDecoration(
            color: AppColors.divider,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBox(width: isSender ? 180 : 150, height: 14),
              const SizedBox(height: 6),
              SkeletonBox(width: isSender ? 100 : 120, height: 14),
            ],
          ),
        ),
      ),
    );
  }
}

/// Skeleton list with multiple items
class SkeletonList extends StatelessWidget {
  final Widget itemBuilder;
  final int itemCount;

  const SkeletonList({
    super.key,
    required this.itemBuilder,
    this.itemCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (context, index) => itemBuilder,
    );
  }
}
