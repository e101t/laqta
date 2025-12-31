import 'package:flutter/material.dart';
import '../theme/laqta_tokens.dart';

class ProfileHeaderParallax extends StatelessWidget {
  final String? coverUrl;
  final String? coverAsset;
  final String name;
  final String? location;
  final String? avatarUrl;
  final List<Widget>? actions;
  final double expandedHeight;

  const ProfileHeaderParallax({
    super.key,
    this.coverUrl,
    this.coverAsset = 'assets/images/placeholder.jpg',
    required this.name,
    this.location,
    this.avatarUrl,
    this.actions,
    this.expandedHeight = 280,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: expandedHeight,
      backgroundColor: LaqtaColors.canvas,
      actions: actions,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: Stack(
          fit: StackFit.expand,
          children: [
            _buildCover(),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.15),
                    Colors.black.withValues(alpha: 0.55),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: LaqtaColors.border,
                    backgroundImage: avatarUrl != null
                        ? NetworkImage(avatarUrl!)
                        : null,
                    child: avatarUrl == null
                        ? const Icon(Icons.person_outline, size: 32)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: Colors.white),
                        ),
                        if (location != null)
                          Text(
                            location!,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.white70),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCover() {
    final url = coverUrl?.trim() ?? '';
    if (url.isNotEmpty) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFallbackCover(),
      );
    }
    return _buildFallbackCover();
  }

  Widget _buildFallbackCover() {
    final asset = coverAsset?.trim() ?? '';
    if (asset.isNotEmpty) {
      return Image.asset(asset, fit: BoxFit.cover);
    }
    return Container(color: LaqtaColors.border);
  }
}
