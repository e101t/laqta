import 'package:flutter/material.dart';
import '../theme/laqta_tokens.dart';
import '../utils/image_provider.dart';
import 'rating_row.dart';
import 'price_tag.dart';

class PhotographerCard extends StatelessWidget {
  final String name;
  final String location;
  final double rating;
  final String price;
  final String? avatarUrl;
  final VoidCallback? onTap;

  const PhotographerCard({
    super.key,
    required this.name,
    required this.location,
    required this.rating,
    required this.price,
    this.avatarUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final imageProvider = resolveImageProvider(avatarUrl);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(LaqtaRadii.l),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: LaqtaColors.surface,
          borderRadius: BorderRadius.circular(LaqtaRadii.l),
          border: Border.all(color: LaqtaColors.border),
          boxShadow: LaqtaShadows.soft,
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: LaqtaColors.border,
              backgroundImage: imageProvider,
              child: imageProvider == null
                  ? const Icon(Icons.camera_alt_outlined)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 4),
                  Text(location, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 6),
                  RatingRow(rating: rating),
                ],
              ),
            ),
            PriceTag(amount: price),
          ],
        ),
      ),
    );
  }
}
