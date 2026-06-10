import 'package:flutter/material.dart';
import 'package:laqta/core/presentation/widgets/shimmers/shimmer_block.dart';

class ChatItemShimmer extends StatelessWidget {
  const ChatItemShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      child: Row(
        children: [
          ShimmerBlock(width: 52, height: 52, borderRadius: 26),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBlock(width: 150, height: 14),
                SizedBox(height: 8),
                ShimmerBlock(width: double.infinity, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
