import 'package:flutter/material.dart';
import 'package:laqta/core/services/backend_media_service.dart';

class BackendMediaImage extends StatefulWidget {
  const BackendMediaImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  @override
  State<BackendMediaImage> createState() => _BackendMediaImageState();
}

class _BackendMediaImageState extends State<BackendMediaImage> {
  final BackendMediaService _mediaService = BackendMediaService();
  late Future<String> _resolvedUrl;

  @override
  void initState() {
    super.initState();
    _resolvedUrl = _mediaService.resolveDisplayUrl(widget.url);
  }

  @override
  void didUpdateWidget(covariant BackendMediaImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _resolvedUrl = _mediaService.resolveDisplayUrl(widget.url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _resolvedUrl,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return _wrap(
            Container(
              width: widget.width,
              height: widget.height,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              alignment: Alignment.center,
              child: const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        if (!snapshot.hasData ||
            snapshot.data == null ||
            snapshot.data!.isEmpty) {
          return _errorPlaceholder();
        }

        return _wrap(
          Image.network(
            snapshot.data!,
            width: widget.width,
            height: widget.height,
            fit: widget.fit,
            errorBuilder: (context, error, stackTrace) => _errorPlaceholder(),
          ),
        );
      },
    );
  }

  Widget _errorPlaceholder() {
    return _wrap(
      Container(
        width: widget.width,
        height: widget.height,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        alignment: Alignment.center,
        child: const Icon(Icons.broken_image_outlined),
      ),
    );
  }

  Widget _wrap(Widget child) {
    final borderRadius = widget.borderRadius;
    if (borderRadius == null) {
      return child;
    }
    return ClipRRect(borderRadius: borderRadius, child: child);
  }
}
