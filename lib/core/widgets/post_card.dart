import 'package:flutter/material.dart';
import '../theme/laqta_tokens.dart';
import '../utils/image_provider.dart';
import 'glass_card.dart';

class PostCard extends StatelessWidget {
  final String authorName;
  final String? authorAvatarUrl;
  final String imageUrl;
  final String caption;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;

  const PostCard({
    super.key,
    required this.authorName,
    required this.imageUrl,
    required this.caption,
    this.authorAvatarUrl,
    this.onLike,
    this.onComment,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final avatarProvider = resolveImageProvider(authorAvatarUrl);
    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: LaqtaColors.border,
                backgroundImage: avatarProvider,
                child: avatarProvider == null
                    ? const Icon(Icons.person_outline)
                    : null,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  authorName,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              const Icon(Icons.more_horiz),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(LaqtaRadii.m),
            child: AspectRatio(aspectRatio: 16 / 9, child: _buildMedia()),
          ),
          const SizedBox(height: 12),
          Text(caption, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 8),
          Row(
            children: [
              IconButton(
                onPressed: onLike,
                icon: const Icon(Icons.favorite_border),
                tooltip: 'أعجبني',
              ),
              IconButton(
                onPressed: onComment,
                icon: const Icon(Icons.chat_bubble_outline),
                tooltip: 'تعليق',
              ),
              const Spacer(),
              IconButton(
                onPressed: onShare,
                icon: const Icon(Icons.share_outlined),
                tooltip: 'مشاركة',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMedia() {
    final provider = resolveImageProvider(imageUrl);
    if (provider == null) {
      return Container(
        color: LaqtaColors.border,
        alignment: Alignment.center,
        child: const Icon(Icons.image_not_supported_outlined),
      );
    }

    return Image(
      image: provider,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: LaqtaColors.border,
          alignment: Alignment.center,
          child: const Icon(Icons.broken_image_outlined),
        );
      },
    );
  }
}
