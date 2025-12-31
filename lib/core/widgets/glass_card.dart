import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/laqta_tokens.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final double blurSigma;
  final Color? tint;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = LaqtaRadii.l,
    this.blurSigma = LaqtaGlass.blurSigma,
    this.tint,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: tint ?? LaqtaColors.glassFill,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: LaqtaColors.glassBorder),
            boxShadow: LaqtaShadows.glass,
          ),
          child: child,
        ),
      ),
    );
  }
}
