import 'package:flutter/material.dart';
import 'package:laqta/core/presentation/widgets/shimmers/shimmer_block.dart';

class NotificationItemShimmer extends StatelessWidget {
  const NotificationItemShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      child: Row(
        children: [
          ShimmerBlock(width: 44, height: 44, borderRadius: 22),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBlock(width: double.infinity, height: 14),
                SizedBox(height: 8),
                ShimmerBlock(width: 170, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
