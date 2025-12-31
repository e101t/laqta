import 'package:flutter/material.dart';
import '../theme/laqta_tokens.dart';

enum LAQTAButtonVariant { primary, secondary, text }

class LAQTAButton extends StatelessWidget {
  final String label;
  final LAQTAButtonVariant variant;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  const LAQTAButton({
    super.key,
    required this.label,
    this.variant = LAQTAButtonVariant.primary,
    this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : icon != null
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18),
              const SizedBox(width: 8),
              Text(label),
            ],
          )
        : Text(label);

    switch (variant) {
      case LAQTAButtonVariant.primary:
        return FilledButton(
          onPressed: isLoading ? null : onPressed,
          child: child,
        );
      case LAQTAButtonVariant.secondary:
        return OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: LaqtaColors.primary,
            side: const BorderSide(color: LaqtaColors.primary),
          ),
          child: child,
        );
      case LAQTAButtonVariant.text:
        return TextButton(
          onPressed: isLoading ? null : onPressed,
          child: child,
        );
    }
  }
}
