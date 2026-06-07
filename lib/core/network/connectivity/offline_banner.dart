import 'dart:async';

import 'package:flutter/material.dart';
import 'package:laqta/core/network/connectivity/connectivity_service.dart';

class OfflineBanner extends StatefulWidget {
  const OfflineBanner({
    super.key,
    required this.child,
    ConnectivityService? connectivityService,
  }) : _connectivityService = connectivityService;

  final Widget child;
  final ConnectivityService? _connectivityService;

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner> {
  late final ConnectivityService _service;
  StreamSubscription<ConnectivityStateSnapshot>? _subscription;
  ConnectivityStateSnapshot? _snapshot;
  bool _visible = false;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _service = widget._connectivityService ?? ConnectivityService();
    _subscription = _service.stream.listen(_onConnectivityChanged);
    unawaited(_service.start());
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _subscription?.cancel();
    if (widget._connectivityService == null) {
      unawaited(_service.dispose());
    }
    super.dispose();
  }

  void _onConnectivityChanged(ConnectivityStateSnapshot snapshot) {
    _hideTimer?.cancel();
    if (!mounted) return;
    if (snapshot.isOffline || snapshot.isDegraded) {
      setState(() {
        _snapshot = snapshot;
        _visible = true;
      });
      return;
    }
    setState(() => _snapshot = snapshot);
    _hideTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _visible = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        PositionedDirectional(
          top: 0,
          start: 0,
          end: 0,
          child: SafeArea(
            bottom: false,
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              offset: _visible ? Offset.zero : const Offset(0, -1.2),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 180),
                opacity: _visible ? 1 : 0,
                child: _Banner(snapshot: _snapshot),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.snapshot});

  final ConnectivityStateSnapshot? snapshot;

  @override
  Widget build(BuildContext context) {
    final isDegraded = snapshot?.isDegraded ?? false;
    final text = isDegraded
        ? 'الاتصال ضعيف، البيانات المعروضة قد لا تكون محدثة'
        : 'لا يوجد اتصال بالإنترنت';
    final lastOnline = snapshot?.lastOnlineAt;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Material(
        color: isDegraded ? const Color(0xFF9A5B00) : const Color(0xFFB3261E),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isDegraded
                    ? Icons.wifi_tethering_error_rounded
                    : Icons.wifi_off,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  lastOnline == null
                      ? text
                      : '$text • آخر اتصال: ${_format(lastOnline)}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _format(DateTime value) {
    final minutes = DateTime.now().difference(value).inMinutes;
    if (minutes <= 0) return 'الآن';
    return 'منذ $minutes دقيقة';
  }
}
