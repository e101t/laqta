import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'package:laqta/core/services/backend_config.dart';

class LaqtaSkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final BorderRadius? borderRadius;

  const LaqtaSkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF1C1F25),
      highlightColor: const Color(0xFF2A2F38),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(16),
        ),
      ),
    );
  }
}

class LaqtaRemoteImage extends StatelessWidget {
  final String? imageUrl;
  final String? fallbackAssetPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? overlay;

  const LaqtaRemoteImage({
    super.key,
    required this.imageUrl,
    this.fallbackAssetPath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.overlay,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedUrl = BackendConfig.resolvePublicUrl(imageUrl);
    final radius = borderRadius ?? BorderRadius.circular(16);
    final overlayWidget = overlay;
    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        width: width,
        height: height,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final cacheWidth = _cacheDimension(
              context,
              width ??
                  (constraints.hasBoundedWidth ? constraints.maxWidth : null),
            );
            final cacheHeight = _cacheDimension(
              context,
              height ??
                  (constraints.hasBoundedHeight ? constraints.maxHeight : null),
            );
            final imageChild = resolvedUrl != null
                ? CachedNetworkImage(
                    imageUrl: resolvedUrl,
                    fit: fit,
                    memCacheWidth: cacheWidth,
                    memCacheHeight: cacheHeight,
                    fadeInDuration: const Duration(milliseconds: 120),
                    fadeOutDuration: const Duration(milliseconds: 80),
                    placeholder: (context, url) => const DecoratedBox(
                      decoration: BoxDecoration(color: Color(0xFF17191F)),
                    ),
                    errorWidget: (context, url, error) => _fallback(),
                  )
                : _fallback();
            final children = <Widget>[imageChild];
            if (overlayWidget != null) {
              children.add(overlayWidget);
            }
            return Stack(fit: StackFit.expand, children: children);
          },
        ),
      ),
    );
  }

  int? _cacheDimension(BuildContext context, double? logicalPixels) {
    if (logicalPixels == null ||
        logicalPixels <= 0 ||
        !logicalPixels.isFinite) {
      return null;
    }
    final physicalPixels =
        (logicalPixels * MediaQuery.devicePixelRatioOf(context)).round().clamp(
          1,
          4096,
        );
    return physicalPixels.toInt();
  }

  Widget _fallback() {
    if (fallbackAssetPath != null && fallbackAssetPath!.trim().isNotEmpty) {
      return Image.asset(fallbackAssetPath!, fit: fit);
    }

    return Container(
      color: const Color(0xFF17191F),
      alignment: Alignment.center,
      child: const Icon(Icons.image_outlined, color: Colors.white38, size: 34),
    );
  }
}
