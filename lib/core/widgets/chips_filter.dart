import 'package:flutter/material.dart';
import '../theme/laqta_tokens.dart';

class ChipsFilter extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const ChipsFilter({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(labels.length, (index) {
          final selected = index == selectedIndex;
          return Padding(
            padding: const EdgeInsetsDirectional.only(end: 8),
            child: ChoiceChip(
              label: Text(labels[index]),
              selected: selected,
              selectedColor: LaqtaColors.primary.withValues(alpha: 0.12),
              backgroundColor: LaqtaColors.surface,
              onSelected: (_) => onSelected(index),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(LaqtaRadii.l),
                side: BorderSide(
                  color: selected ? LaqtaColors.primary : LaqtaColors.border,
                ),
              ),
              labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: selected ? LaqtaColors.primary : LaqtaColors.ink,
              ),
            ),
          );
        }),
      ),
    );
  }
}
