import 'package:flutter/material.dart';
import 'package:laqta/core/presentation/widgets/shimmers/shimmer_block.dart';

class ProfileHeaderShimmer extends StatelessWidget {
  const ProfileHeaderShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          ShimmerBlock(width: double.infinity, height: 170, borderRadius: 22),
          SizedBox(height: 12),
          Row(
            children: [
              ShimmerBlock(width: 72, height: 72, borderRadius: 36),
              SizedBox(width: 12),
              Expanded(child: ShimmerBlock(width: null, height: 20)),
            ],
          ),
        ],
      ),
    );
  }
}
