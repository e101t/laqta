import 'package:flutter/material.dart';

import 'package:laqta/core/presentation/widgets/shimmers/shimmer_block.dart';

/// Skeleton that matches the layout of _CreatorMoodCard in ExploreScreen.
/// Avatar(48) | name + location row + price | arrow
class CreatorCardShimmer extends StatelessWidget {
  const CreatorCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF17191F),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // avatar circle
          const ShimmerBlock(width: 52, height: 52, borderRadius: 26),
          const SizedBox(width: 12),
          // text column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBlock(width: MediaQuery.sizeOf(context).width * 0.30, height: 14),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const ShimmerBlock(width: 60, height: 11),
                    const SizedBox(width: 8),
                    const ShimmerBlock(width: 48, height: 20, borderRadius: 999),
                  ],
                ),
                const SizedBox(height: 6),
                const ShimmerBlock(width: 80, height: 11),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // arrow placeholder
          const ShimmerBlock(width: 16, height: 16, borderRadius: 4),
        ],
      ),
    );
  }
}

/// Stacks several CreatorCardShimmers to fill the explore loading state.
class ExploreCreatorsShimmer extends StatelessWidget {
  const ExploreCreatorsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        4,
        (i) => Padding(
          padding: EdgeInsets.only(bottom: i < 3 ? 10 : 0),
          child: const CreatorCardShimmer(),
        ),
      ),
    );
  }
}
