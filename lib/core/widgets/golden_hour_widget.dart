import 'package:flutter/material.dart';

import 'package:laqta/core/theme/laqta_tokens.dart';

/// Contextual banner surfacing today's golden hour and how many
/// photographers are available right now. Purely presentational —
/// all data is passed in.
class GoldenHourBanner extends StatelessWidget {
  final String city;
  final String time;
  final int availableCount;
  final VoidCallback? onTap;

  const GoldenHourBanner({
    super.key,
    required this.city,
    required this.time,
    required this.availableCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 70),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFF1A1400), Color(0xFF0E1014)],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: LaqtaColors.accent.withValues(alpha: 0.22),
          ),
          boxShadow: [
            BoxShadow(
              color: LaqtaColors.accent.withValues(alpha: 0.10),
              blurRadius: 22,
              offset: const Offset(-6, 0),
            ),
          ],
        ),
        child: Row(
          textDirection: TextDirection.ltr,
          children: [
            const _PulsingShutterIcon(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'الساعة الذهبية في $city: $time',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$availableCount مصورين متاحون الآن',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: LaqtaColors.accent,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: LaqtaColors.accent,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

/// Camera shutter icon whose opacity pulses between 0.6 and 1.0 every 2s.
class _PulsingShutterIcon extends StatefulWidget {
  const _PulsingShutterIcon();

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
    _opacity = Tween<double>(begin: 0.6, end: 1.0).animate(
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
      opacity: _opacity,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: LaqtaColors.accent.withValues(alpha: 0.12),
          border: Border.all(
            color: LaqtaColors.accent.withValues(alpha: 0.35),
          ),
        ),
        child: const Icon(
          Icons.camera_rounded,
          color: LaqtaColors.accent,
          size: 22,
        ),
      ),
    );
  }
}
