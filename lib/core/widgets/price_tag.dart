import 'package:flutter/material.dart';
import '../theme/laqta_tokens.dart';

class PriceTag extends StatelessWidget {
  final String amount;
  final String currency;

  const PriceTag({super.key, required this.amount, this.currency = 'IQD'});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: LaqtaColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$amount $currency',
        style: Theme.of(
          context,
        ).textTheme.labelSmall?.copyWith(color: LaqtaColors.primary),
      ),
    );
  }
}
