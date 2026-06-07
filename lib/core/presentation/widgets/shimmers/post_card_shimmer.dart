import 'package:flutter/material.dart';
import 'package:laqta/core/presentation/widgets/shimmers/shimmer_block.dart';

class PostCardShimmer extends StatelessWidget {
  const PostCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBlock(width: double.infinity, height: 210, borderRadius: 22),
          SizedBox(height: 10),
          ShimmerBlock(width: 180, height: 16),
          SizedBox(height: 7),
          ShimmerBlock(width: 110, height: 12),
        ],
      ),
    );
  }
}
