import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:laqta/app/router/routes.dart';
import 'package:laqta/core/security/monitoring/security_event_logger.dart';

class DeepLinkHandler {
  DeepLinkHandler({AppLinks? appLinks, SecurityEventLogger? securityLogger})
    : _appLinks = appLinks ?? AppLinks(),
      _securityLogger = securityLogger ?? SecurityEventLogger.instance;

  DeepLinkHandler.forTesting({SecurityEventLogger? securityLogger})
    : _appLinks = null,
      _securityLogger = securityLogger ?? SecurityEventLogger.instance;

  final AppLinks? _appLinks;
  final SecurityEventLogger _securityLogger;
  StreamSubscription<Uri>? _subscription;
  Uri? _pendingInitialUri;
  GoRouter? _router;

  Future<void> initialize(GoRouter router) async {
    _router = router;
    try {
      _pendingInitialUri = await _appLinks?.getInitialLink();
    } catch (_) {
      _pendingInitialUri = null;
    }
    final stream = _appLinks?.uriLinkStream;
    if (stream != null) {
      _subscription ??= stream.listen(_handleUri);
    }
  }

  void flushPendingInitialLink() {
    final uri = _pendingInitialUri;
    if (uri == null) return;
    _pendingInitialUri = null;
    _handleUri(uri);
  }

  @visibleForTesting
  String? resolve(Uri uri) {
    if (!_isAllowedScheme(uri)) return null;
    if (_hasUnsafeParts(uri)) return null;

    final segments = _normalizedSegments(uri);
    if (segments.isEmpty) return null;

    switch (segments.first) {
      case 'explore':
        return segments.length == 1 ? Routes.explore : null;
      case 'chat':
        return segments.length == 2
            ? Routes.chat.replaceFirst(':id', Uri.encodeComponent(segments[1]))
            : null;
      case 'profile':
        return segments.length == 2
            ? Routes.photographer.replaceFirst(
                ':id',
                Uri.encodeComponent(segments[1]),
              )
            : null;
      case 'post':
        return segments.length == 2 ? Routes.main : null;
      default:
        return null;
    }
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
    _router = null;
    _pendingInitialUri = null;
  }

  void _handleUri(Uri uri) {
    final path = resolve(uri);
    if (path == null) {
      unawaited(
        _securityLogger.log(
          'invalid_deep_link',
          severity: 'warning',
          details: <String, Object?>{'uri': uri.toString()},
        ),
      );
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _router?.push(path);
    });
  }

  bool _isAllowedScheme(Uri uri) {
    if (uri.scheme == 'https') return uri.host == 'laqta.app';
    if (uri.scheme == 'laqta') return true;
    return false;
  }

  bool _hasUnsafeParts(Uri uri) {
    if (uri.queryParameters.isNotEmpty) return true;
    final raw = uri.toString().toLowerCase();
    return raw.contains('../') || raw.contains('%2e%2e');
  }

  List<String> _normalizedSegments(Uri uri) {
    if (uri.scheme == 'laqta') {
      final segments = <String>[];
      if (uri.host.isNotEmpty) segments.add(uri.host);
      segments.addAll(uri.pathSegments);
      return segments.where((part) => part.trim().isNotEmpty).toList();
    }
    return uri.pathSegments.where((part) => part.trim().isNotEmpty).toList();
  }
}
