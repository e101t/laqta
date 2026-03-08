import 'package:flutter/material.dart';
import '../theme/laqta_tokens.dart';
import '../utils/image_provider.dart';

class StoryBubble extends StatelessWidget {
  final String title;
  final String? imageUrl;
  final bool isViewed;
  final bool isAdd;
  final VoidCallback? onTap;

  const StoryBubble({
    super.key,
    required this.title,
    this.imageUrl,
    this.isViewed = false,
    this.isAdd = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isAdd
        ? LaqtaColors.accent
        : isViewed
        ? LaqtaColors.border
        : LaqtaColors.primary;
    final imageProvider = resolveImageProvider(imageUrl);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: borderColor, width: 2),
            ),
            child: CircleAvatar(
              radius: 26,
              backgroundColor: LaqtaColors.surface,
              backgroundImage: imageProvider,
              child: imageProvider == null
                  ? Icon(
                      isAdd ? Icons.add : Icons.person_outline,
                      color: LaqtaColors.inkMuted,
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 72,
            child: Text(
              title,
              style: Theme.of(context).textTheme.labelSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
