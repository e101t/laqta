import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:laqta/core/localization/app_localizations.dart';
import 'package:laqta/core/network/certificate_pinning.dart';

class PinMismatchScreen extends StatelessWidget {
  const PinMismatchScreen({super.key, this.failure});

  final CertificatePinningException? failure;

  @override
  Widget build(BuildContext context) {
    // May render above the MaterialApp localization scope, so resolve the
    // active locale directly.
    final localizations = AppLocalizations.resolve(context);
    final direction = localizations.locale.languageCode == 'ar'
        ? TextDirection.rtl
        : TextDirection.ltr;
    return Material(
      color: const Color(0xFF090B0F),
      child: Directionality(
        textDirection: direction,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.security_update_warning_rounded,
                  color: Color(0xFFE7B85A),
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  localizations.securityMaintenanceTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  kReleaseMode
                      ? localizations.secureConnectionFailed
                      : failure?.toString() ?? 'TLS pin mismatch',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFF9CA3AF)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
