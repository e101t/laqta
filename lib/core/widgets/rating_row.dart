import 'package:flutter/material.dart';
import '../theme/laqta_tokens.dart';

class RatingRow extends StatelessWidget {
  final double rating;
  final int? count;

  const RatingRow({super.key, required this.rating, this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.star, size: 16, color: LaqtaColors.warning),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: Theme.of(context).textTheme.labelSmall,
        ),
        if (count != null) ...[
          const SizedBox(width: 4),
          Text('($count)', style: Theme.of(context).textTheme.labelSmall),
        ],
      ],
    );
  }
}
