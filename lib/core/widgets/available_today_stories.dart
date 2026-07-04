import 'package:flutter/material.dart';

import 'package:laqta/core/theme/laqta_tokens.dart';
import 'package:laqta/core/widgets/laqta_async_widgets.dart';

/// A photographer entry for the "available today" stories row.
class AvailableTodayItem {
  final String id;
  final String name;
  final String? photoUrl;
  final String fallbackAsset;

  const AvailableTodayItem({
    required this.id,
    required this.name,
    this.photoUrl,
    required this.fallbackAsset,
  });
}

/// Instagram-style stories row showing photographers available today.
///
/// Each avatar wears a gold ring with a pulsing gold "live" dot at its
/// bottom-right corner. Renders nothing when [photographers] is empty.
class AvailableTodayStories extends StatelessWidget {
  final List<AvailableTodayItem> photographers;
  final void Function(AvailableTodayItem item)? onTapItem;

  const AvailableTodayStories({
    super.key,
    required this.photographers,
    this.onTapItem,
  });

  @override
  Widget build(BuildContext context) {
    if (photographers.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'متاح اليوم',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 84,
          child: ListView.separated(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: photographers.length,
            separatorBuilder: (_, _) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final item = photographers[index];
              return _StoryBubble(
                item: item,
                onTap: onTapItem == null ? null : () => onTapItem!(item),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _StoryBubble extends StatelessWidget {
  final AvailableTodayItem item;
  final VoidCallback? onTap;

  const _StoryBubble({required this.item, this.onTap});

  String get _shortName {
    final name = item.name.trim();
    if (name.isEmpty) return '';
    return name.length <= 7 ? name : name.substring(0, 7);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 58,
            height: 58,
            child: Stack(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: LaqtaColors.accent, width: 2),
                  ),
                  child: ClipOval(
                    child: LaqtaRemoteImage(
                      imageUrl: item.photoUrl,
                      fallbackAssetPath: item.fallbackAsset,
                      width: 52,
                      height: 52,
                      fit: BoxFit.cover,
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                ),
                const Positioned(bottom: 1, right: 1, child: _PulsingDot()),
              ],
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 58,
            child: Text(
              _shortName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Small gold dot that pulses between 0.85 and 1.0 scale.
class _PulsingDot extends StatefulWidget {
  const _PulsingDot();

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: LaqtaColors.accent,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF0E1014), width: 2),
        ),
      ),
    );
  }
}
