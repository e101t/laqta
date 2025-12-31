import 'package:flutter/material.dart';
import 'package:luqta/core/constants/app_constants.dart';

/// Animation Utilities
class AppAnimations {
  // Duration helpers
  static Duration get shortDuration =>
      const Duration(milliseconds: AppConstants.animationDurationShort);

  static Duration get mediumDuration =>
      const Duration(milliseconds: AppConstants.animationDurationMedium);

  static Duration get longDuration =>
      const Duration(milliseconds: AppConstants.animationDurationLong);

  // Reduced motion durations (40% less)
  static Duration get shortDurationReduced => Duration(
    milliseconds: (AppConstants.animationDurationShort * 0.6).round(),
  );

  static Duration get mediumDurationReduced => Duration(
    milliseconds: (AppConstants.animationDurationMedium * 0.6).round(),
  );

  static Duration get longDurationReduced => Duration(
    milliseconds: (AppConstants.animationDurationLong * 0.6).round(),
  );

  // Curves
  static const Curve easeIn = Curves.easeIn;
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeInOut = Curves.easeInOutCubic;
  static const Curve spring = Curves.elasticOut;

  // Standard page transition
  static Widget pageTransition({
    required Widget child,
    required Animation<double> animation,
    bool slideFromBottom = false,
  }) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: slideFromBottom ? const Offset(0, 0.1) : const Offset(0.1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: easeOut)),
        child: child,
      ),
    );
  }

  // Fade transition
  static Widget fadeTransition({
    required Widget child,
    required Animation<double> animation,
  }) {
    return FadeTransition(opacity: animation, child: child);
  }

  // Scale transition
  static Widget scaleTransition({
    required Widget child,
    required Animation<double> animation,
  }) {
    return ScaleTransition(
      scale: Tween<double>(
        begin: 0.9,
        end: 1.0,
      ).animate(CurvedAnimation(parent: animation, curve: easeOut)),
      child: FadeTransition(opacity: animation, child: child),
    );
  }

  // Slide from right
  static Widget slideFromRight({
    required Widget child,
    required Animation<double> animation,
  }) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: easeOut)),
      child: child,
    );
  }

  // Slide from left
  static Widget slideFromLeft({
    required Widget child,
    required Animation<double> animation,
  }) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(-1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: easeOut)),
      child: child,
    );
  }

  // Shimmer effect for loading skeleton
  static LinearGradient shimmerGradient({required double animationValue}) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: const [Color(0xFFE0E0E0), Color(0xFFF5F5F5), Color(0xFFE0E0E0)],
      stops: [
        animationValue - 0.3,
        animationValue,
        animationValue + 0.3,
      ].map((stop) => stop.clamp(0.0, 1.0)).toList(),
    );
  }
}

/// Staggered Animation Helper
class StaggeredAnimationHelper {
  final int itemCount;
  final Duration duration;
  final Duration delay;

  const StaggeredAnimationHelper({
    required this.itemCount,
    this.duration = const Duration(milliseconds: 240),
    this.delay = const Duration(milliseconds: 50),
  });

  Duration getDelay(int index) {
    return delay * index;
  }
}
