import 'package:flutter/material.dart';

/// One selectable photography mood.
class MoodOption {
  final String id;
  final String label;
  final IconData icon;
  final Color moodColor;

  const MoodOption({
    required this.id,
    required this.label,
    required this.icon,
    required this.moodColor,
  });
}

/// Visual mood selector — horizontally scrollable cards, each carrying an
/// icon and a color swatch that represents a photography mood.
///
/// Tapping the selected mood again deselects it (calls `onSelect(null)`).
class MoodFilter extends StatefulWidget {
  final List<MoodOption> moods;
  final String? selectedMoodId;
  final void Function(String? moodId) onSelect;

  const MoodFilter({
    super.key,
    this.moods = MoodFilter.defaults,
    this.selectedMoodId,
    required this.onSelect,
  });

  static const List<MoodOption> defaults = [
    MoodOption(
      id: 'warm',
      label: 'دافئ وناعم',
      icon: Icons.wb_sunny_outlined,
      moodColor: Color(0xFFD6A44A),
    ),
    MoodOption(
      id: 'urban',
      label: 'حضري وحاد',
      icon: Icons.location_city_outlined,
      moodColor: Color(0xFF5B8DEF),
    ),
    MoodOption(
      id: 'romantic',
      label: 'رومانسي',
      icon: Icons.favorite_outline,
      moodColor: Color(0xFFE85D9A),
    ),
    MoodOption(
      id: 'outdoor',
      label: 'طبيعي خارجي',
      icon: Icons.landscape_outlined,
      moodColor: Color(0xFF4CAF50),
    ),
    MoodOption(
      id: 'dramatic',
      label: 'درامي وعميق',
      icon: Icons.contrast_outlined,
      moodColor: Color(0xFF9C27B0),
    ),
  ];

  @override
  State<MoodFilter> createState() => _MoodFilterState();
}

class _MoodFilterState extends State<MoodFilter> {
  @override
  Widget build(BuildContext context) {
    if (widget.moods.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 52,
      child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: widget.moods.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final mood = widget.moods[index];
          final selected = mood.id == widget.selectedMoodId;
          return _MoodCard(
            mood: mood,
            selected: selected,
            onTap: () => widget.onSelect(selected ? null : mood.id),
          );
        },
      ),
    );
  }
}

class _MoodCard extends StatelessWidget {
  final MoodOption mood;
  final bool selected;
  final VoidCallback onTap;

  const _MoodCard({
    required this.mood,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        width: selected ? 132 : 90,
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: selected
              ? mood.moodColor.withValues(alpha: 0.15)
              : const Color(0xFF17191F),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? mood.moodColor : const Color(0xFF2A2D33),
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(mood.icon, color: mood.moodColor, size: 20),
            if (selected) ...[
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  mood.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: mood.moodColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ] else ...[
              const SizedBox(width: 6),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: mood.moodColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
