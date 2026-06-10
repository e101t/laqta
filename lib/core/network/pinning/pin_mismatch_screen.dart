import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:laqta/core/network/certificate_pinning.dart';

class PinMismatchScreen extends StatelessWidget {
  const PinMismatchScreen({super.key, this.failure});

  final CertificatePinningException? failure;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF090B0F),
      child: Directionality(
        textDirection: TextDirection.rtl,
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
                const Text(
                  'الخدمة قيد الصيانة الأمنية',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  kReleaseMode
                      ? 'تعذر التحقق من الاتصال الآمن. حاول لاحقًا.'
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
