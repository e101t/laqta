import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:laqta/core/theme/laqta_tokens.dart';

// ---------------------------------------------------------------------------
// A) ShutterHeartButton
// ---------------------------------------------------------------------------

/// Favorite button with a camera-shutter flourish.
///
/// On tap it plays three frames: (1) an aperture-like rotation while scaling
/// down, (2) the filled heart pops in with a scale bounce, (3) three small
/// gold sparkle dots radiate outward and fade.
class ShutterHeartButton extends StatefulWidget {
  final bool isFavorited;
  final VoidCallback onToggle;
  final double size;

  const ShutterHeartButton({
    super.key,
    required this.isFavorited,
    required this.onToggle,
    this.size = 22,
  });

  @override
  State<ShutterHeartButton> createState() => _ShutterHeartButtonState();
}

class _ShutterHeartButtonState extends State<ShutterHeartButton>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _shutterRotation;
  late final Animation<double> _shutterScale;
  late final Animation<double> _heartScale;
  late final Animation<double> _sparkleProgress;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    // Frame 1: shutter twist — rotate 30 degrees, scale to 0.8.
    _shutterRotation = Tween<double>(begin: 0, end: math.pi / 6).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.25, curve: Curves.easeIn),
      ),
    );
    _shutterScale = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.25, curve: Curves.easeIn),
      ),
    );

    // Frame 2: heart bounce 1.0 -> 1.4 -> 1.0.
    _heartScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.4), weight: 55),
      TweenSequenceItem(tween: Tween(begin: 1.4, end: 1.0), weight: 45),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.25, 0.65, curve: Curves.easeOut),
      ),
    );

    // Frame 3: sparkles radiate outward and fade.
    _sparkleProgress = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.45, 1.0, curve: Curves.easeOut),
    );

    if (widget.isFavorited) _controller.value = 1.0;
  }

  @override
  void didUpdateWidget(covariant ShutterHeartButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFavorited != oldWidget.isFavorited) {
      if (widget.isFavorited) {
        _controller.forward(from: 0);
      } else {
        _controller.value = 0;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.lightImpact();
    widget.onToggle();
    // Play the animation optimistically when moving into favorited state.
    if (!widget.isFavorited) {
      _controller.forward(from: 0);
    } else {
      _controller.value = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final box = widget.size * 2;
    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: box,
        height: box,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final showFilled = _controller.value >= 0.25;
            return Stack(
              alignment: Alignment.center,
              children: [
                // Sparkles behind/around the heart.
                if (_sparkleProgress.value > 0 &&
                    _sparkleProgress.value < 1)
                  CustomPaint(
                    size: Size(box, box),
                    painter: _SparklePainter(
                      progress: _sparkleProgress.value,
                      color: LaqtaColors.accent,
                    ),
                  ),
                if (!showFilled)
                  Transform.rotate(
                    angle: _shutterRotation.value,
                    child: Transform.scale(
                      scale: _shutterScale.value,
                      child: Icon(
                        Icons.favorite_border_rounded,
                        color: Colors.white,
                        size: widget.size,
                      ),
                    ),
                  )
                else
                  Transform.scale(
                    scale: _heartScale.value.clamp(0.0, 1.4),
                    child: Icon(
                      Icons.favorite_rounded,
                      color: LaqtaColors.accent,
                      size: widget.size,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SparklePainter extends CustomPainter {
  final double progress;
  final Color color;

  const _SparklePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = color.withValues(alpha: (1 - progress).clamp(0.0, 1.0));
    final radius = size.shortestSide * 0.22 +
        size.shortestSide * 0.28 * progress;
    const angles = [-math.pi / 2, math.pi / 6, 5 * math.pi / 6];
    for (final angle in angles) {
      final offset = center +
          Offset(math.cos(angle) * radius, math.sin(angle) * radius);
      canvas.drawCircle(offset, 2.2 * (1 - progress * 0.5), paint);
    }
  }

  @override
  bool shouldRepaint(_SparklePainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}

// ---------------------------------------------------------------------------
// B) BookingConfettiWrapper
// ---------------------------------------------------------------------------

/// Wraps any child and can shower gold + white confetti over it.
///
/// Hold a `GlobalKey<BookingConfettiWrapperState>` and call
/// `key.currentState?.trigger()` to fire the burst. Confetti fades out
/// after ~1.4 seconds.
class BookingConfettiWrapper extends StatefulWidget {
  final Widget child;

  const BookingConfettiWrapper({super.key, required this.child});

  @override
  State<BookingConfettiWrapper> createState() => BookingConfettiWrapperState();
}

class BookingConfettiWrapperState extends State<BookingConfettiWrapper>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  List<_ConfettiParticle> _particles = const [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed && mounted) {
          setState(() => _particles = const []);
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Fires a fresh confetti burst.
  void trigger() {
    final random = math.Random();
    _particles = List.generate(18, (index) {
      return _ConfettiParticle(
        origin: Offset(0.15 + random.nextDouble() * 0.7, 1.0),
        velocity: Offset(
          (random.nextDouble() - 0.5) * 0.6,
          -(0.9 + random.nextDouble() * 0.9),
        ),
        size: 4 + random.nextDouble() * 4,
        color: index.isEven ? LaqtaColors.accent : Colors.white,
        isCircle: random.nextBool(),
        spin: (random.nextDouble() - 0.5) * 6,
      );
    });
    setState(() {});
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        widget.child,
        if (_particles.isNotEmpty)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) => CustomPaint(
                  painter: _ConfettiPainter(
                    particles: _particles,
                    progress: _controller.value,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ConfettiParticle {
  final Offset origin; // fractional coordinates (0..1)
  final Offset velocity; // fractional per full animation
  final double size;
  final Color color;
  final bool isCircle;
  final double spin;

  const _ConfettiParticle({
    required this.origin,
    required this.velocity,
    required this.size,
    required this.color,
    required this.isCircle,
    required this.spin,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;

  const _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final opacity = (1 - progress).clamp(0.0, 1.0);
    for (final particle in particles) {
      // Upward flight with slight gravity pull-back near the end.
      final dx = particle.origin.dx + particle.velocity.dx * progress;
      final dy = particle.origin.dy +
          particle.velocity.dy * progress +
          0.35 * progress * progress;
      final position = Offset(dx * size.width, dy * size.height);
      final paint = Paint()
        ..color = particle.color.withValues(alpha: opacity);

      if (particle.isCircle) {
        canvas.drawCircle(position, particle.size / 2, paint);
      } else {
        canvas.save();
        canvas.translate(position.dx, position.dy);
        canvas.rotate(particle.spin * progress);
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: particle.size,
            height: particle.size,
          ),
          paint,
        );
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.particles != particles;
}

// ---------------------------------------------------------------------------
// C) StarLightsRating
// ---------------------------------------------------------------------------

/// Star rating whose stars light up sequentially (50ms apart), each with a
/// brief gold glow as it ignites.
class StarLightsRating extends StatefulWidget {
  final int value;
  final int max;
  final double size;

  const StarLightsRating({
    super.key,
    required this.value,
    this.max = 5,
    this.size = 20,
  });

  @override
  State<StarLightsRating> createState() => _StarLightsRatingState();
}

class _StarLightsRatingState extends State<StarLightsRating>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 50 * widget.max + 250),
    );
    if (widget.value > 0) _controller.forward();
  }

  @override
  void didUpdateWidget(covariant StarLightsRating oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final max = widget.max < 1 ? 1 : widget.max;
    final lit = widget.value.clamp(0, max);
    final total = _controller.duration!.inMilliseconds.toDouble();

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(max, (index) {
            final startMs = index * 50.0;
            final start = (startMs / total).clamp(0.0, 0.99);
            final end = ((startMs + 250) / total).clamp(start + 0.01, 1.0);
            final local = ((_controller.value - start) / (end - start))
                .clamp(0.0, 1.0);
            final isLit = index < lit && local > 0;
            // Glow rises then fades within each star's window.
            final glow = isLit ? math.sin(local * math.pi) : 0.0;

            return Container(
              decoration: glow > 0.05
                  ? BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: LaqtaColors.accent
                              .withValues(alpha: 0.55 * glow),
                          blurRadius: 10 * glow,
                          spreadRadius: 1.5 * glow,
                        ),
                      ],
                    )
                  : null,
              child: Icon(
                isLit ? Icons.star_rounded : Icons.star_outline_rounded,
                size: widget.size,
                color: isLit
                    ? LaqtaColors.accent
                    : Colors.white.withValues(alpha: 0.3),
              ),
            );
          }),
        );
      },
    );
  }
}
