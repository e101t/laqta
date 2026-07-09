import 'dart:async';

import 'package:flutter/material.dart';
import 'package:laqta/core/localization/app_localizations.dart';

import 'package:laqta/core/theme/laqta_tokens.dart';
import 'package:laqta/core/utils/golden_hour_service.dart';

/// Contextual banner showing real golden-hour data calculated from device time.
/// Refreshes automatically every minute.
/// [photographerCount] if non-null, shows "X مصور متاح" inside the banner.
class GoldenHourBanner extends StatefulWidget {
  final VoidCallback? onTap;
  final int? photographerCount;

  const GoldenHourBanner({super.key, this.onTap, this.photographerCount});

  @override
  State<GoldenHourBanner> createState() => _GoldenHourBannerState();
}

class _GoldenHourBannerState extends State<GoldenHourBanner> {
  late GoldenHourData _data;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _data = GoldenHourService.compute();
    // refresh every minute so the display stays accurate
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() => _data = GoldenHourService.compute());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 70),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: AlignmentDirectional.centerStart,
            end: AlignmentDirectional.centerEnd,
            colors: _data.isActive
                ? [const Color(0xFF201600), const Color(0xFF0E1014)]
                : [const Color(0xFF141414), const Color(0xFF0E1014)],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _data.isActive
                ? LaqtaColors.accent.withValues(alpha: 0.40)
                : LaqtaColors.accent.withValues(alpha: 0.15),
          ),
          boxShadow: _data.isActive
              ? [
                  BoxShadow(
                    color: LaqtaColors.accent.withValues(alpha: 0.14),
                    blurRadius: 22,
                    offset: const Offset(-6, 0),
                  ),
                ]
              : const [],
        ),
        child: Row(
          children: [
            _PulsingShutterIcon(active: _data.isActive),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _data.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _data.isActive ? Colors.white : Colors.white70,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _data.isActive
                        ? AppLocalizations.current.happeningNow(_data.timeDisplay)
                        : _data.countdownText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _data.isActive
                          ? LaqtaColors.accent
                          : Colors.white38,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            if (widget.photographerCount != null &&
                widget.photographerCount! > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: LaqtaColors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: LaqtaColors.accent.withValues(alpha: 0.35),
                  ),
                ),
                child: Text(
                  AppLocalizations.current.photographersCount(widget.photographerCount!),
                  style: const TextStyle(
                    color: LaqtaColors.accent,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: _data.isActive ? LaqtaColors.accent : Colors.white24,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

class _PulsingShutterIcon extends StatefulWidget {
  final bool active;
  const _PulsingShutterIcon({required this.active});

  @override
  State<_PulsingShutterIcon> createState() => _PulsingShutterIconState();
}

class _PulsingShutterIconState extends State<_PulsingShutterIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.5, end: 1.0).animate(
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
    return FadeTransition(
      opacity: widget.active ? _opacity : const AlwaysStoppedAnimation(0.4),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: LaqtaColors.accent.withValues(
            alpha: widget.active ? 0.15 : 0.06,
          ),
          border: Border.all(
            color: LaqtaColors.accent.withValues(
              alpha: widget.active ? 0.45 : 0.18,
            ),
          ),
        ),
        child: Icon(
          Icons.camera_rounded,
          color: LaqtaColors.accent.withValues(
            alpha: widget.active ? 1.0 : 0.45,
          ),
          size: 22,
        ),
      ),
    );
  }
}
