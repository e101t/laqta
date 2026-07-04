import 'package:flutter/material.dart';

/// A single entry in a [MasonryGrid].
///
/// [aspectRatio] is width / height — e.g. `0.75` renders a portrait tile,
/// `1.33` a landscape one.
class MasonryItem {
  final Widget child;
  final double aspectRatio;

  const MasonryItem({required this.child, this.aspectRatio = 1.0});
}

/// Variable-height masonry grid built with pure Flutter (no packages).
///
/// Items are distributed across [columns] using a shortest-column-first
/// algorithm so the columns stay visually balanced. Each item keeps its
/// natural proportions via [MasonryItem.aspectRatio].
class MasonryGrid extends StatelessWidget {
  final List<MasonryItem> items;
  final int columns;
  final double gap;

  const MasonryGrid({
    super.key,
    required this.items,
    this.columns = 2,
    this.gap = 8,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final columnCount = columns < 1 ? 1 : columns;

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final columnWidth =
            (totalWidth - gap * (columnCount - 1)) / columnCount;
        if (columnWidth <= 0) return const SizedBox.shrink();

        // Shortest-column-first distribution.
        final columnItems = List.generate(
          columnCount,
          (_) => <MasonryItem>[],
          growable: false,
        );
        final columnHeights = List<double>.filled(columnCount, 0);

        for (final item in items) {
          final ratio = item.aspectRatio <= 0 ? 1.0 : item.aspectRatio;
          var shortest = 0;
          for (var i = 1; i < columnCount; i++) {
            if (columnHeights[i] < columnHeights[shortest]) shortest = i;
          }
          columnItems[shortest].add(item);
          columnHeights[shortest] += columnWidth / ratio + gap;
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < columnCount; i++) ...[
              if (i > 0) SizedBox(width: gap),
              Expanded(
                child: Column(
                  children: [
                    for (var j = 0; j < columnItems[i].length; j++) ...[
                      if (j > 0) SizedBox(height: gap),
                      SizedBox(
                        height: columnWidth /
                            (columnItems[i][j].aspectRatio <= 0
                                ? 1.0
                                : columnItems[i][j].aspectRatio),
                        width: double.infinity,
                        child: columnItems[i][j].child,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
