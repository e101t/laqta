import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:luqta/core/constants/app_theme.dart';
import 'package:luqta/core/constants/app_constants.dart';
import 'package:luqta/core/localization/app_localizations.dart';
import 'package:luqta/core/router/app_router.dart';
import 'package:luqta/core/utils/responsive.dart';
import 'package:luqta/core/widgets/app_buttons.dart';
import 'package:luqta/core/widgets/app_text_field.dart';
import 'package:luqta/features/auth/auth_dependencies.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  static Future<void>? _googleSignInInit;
  bool _isLoading = false;
  bool _showPhoneAuth = false; // ابدأ بعرض خيارات الدخول أولاً
  bool _showOTPVerification = false;
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  int _resendTimer = 0;
  String? _verificationId;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  bool get _isGoogleSignInSupported {
    if (!GoogleSignIn.instance.supportsAuthenticate()) {
      return false;
    }
    if (kIsWeb) {
      return true;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return true;
      default:
        return false;
    }
  }

  bool get _isPhoneAuthSupported {
    // Phone authentication is only supported on Android and iOS
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
        return true;
      default:
        return false;
    }
  }

  Future<void> _ensureGoogleSignInInitialized() {
    return _googleSignInInit ??= GoogleSignIn.instance.initialize();
  }

  Future<void> _signInWithGoogle() async {
    final localizations = AppLocalizations.of(context);

    if (!_isGoogleSignInSupported) {
      _showSnackBar(localizations.googleSignInUnsupported);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _ensureGoogleSignInInitialized();
      final result = await AuthDependencies.signInWithGoogle().call();
      if (!result.isSuccess) {
        final failure = result.failureOrNull;
        if (kDebugMode) {
          final code = failure?.code;
          debugPrint('Google sign-in failed: ${code ?? 'unknown'}');
        }
        if (failure?.code == 'canceled') {
          return;
        }
        if (!mounted) return;
        _showSnackBar(
          _formatErrorMessage(
            localizations.googleSignInFailed,
            failure?.message,
          ),
        );
        return;
      }
      if (!mounted) return;
      AppRouter.goToRole(context);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(
        _formatErrorMessage(localizations.googleSignInFailed, e.toString()),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithApple() async {
    final localizations = AppLocalizations.of(context);
    _showSnackBar(localizations.appleSignInUnavailable);
  }

  Future<void> _signInWithPhone() async {
    final localizations = AppLocalizations.of(context);

    if (!_isPhoneAuthSupported) {
      _showSnackBar(localizations.phoneAuthUnsupported);
      return;
    }

    if (_phoneController.text.isEmpty) {
      _showSnackBar(localizations.phoneNumberRequired);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await AuthDependencies.verifyPhoneNumber().call(
        phoneNumber: _phoneController.text,
        onVerificationCompleted: (_) {
          if (!mounted) return;
          setState(() => _isLoading = false);
          AppRouter.goToRole(context);
        },
        onVerificationFailed: (failure) {
          if (!mounted) return;
          if (kDebugMode) {
            final code = failure.code;
            debugPrint('Phone verification failed: ${code ?? 'unknown'}');
          }
          _showSnackBar(
            _formatErrorMessage(
              localizations.verificationFailed,
              failure.message,
            ),
          );
          setState(() => _isLoading = false);
        },
        onCodeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          if (!mounted) return;
          setState(() {
            _isLoading = false;
            _showOTPVerification = true;
            _resendTimer = AppConstants.otpResendSeconds;
          });
          _startResendTimer();
        },
        onCodeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
      if (!result.isSuccess) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        _showSnackBar(
          _formatErrorMessage(
            localizations.phoneAuthError,
            result.failureOrNull?.message,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      _showSnackBar(
        _formatErrorMessage(localizations.phoneAuthError, e.toString()),
      );
    }
  }

  Future<void> _verifyOTP() async {
    final localizations = AppLocalizations.of(context);

    if (_otpController.text.length != AppConstants.otpLength) {
      _showSnackBar(localizations.otpInvalid);
      return;
    }

    if (_verificationId == null) {
      _showSnackBar(localizations.verificationIdMissing);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await AuthDependencies.signInWithPhoneCredential().call(
        verificationId: _verificationId!,
        smsCode: _otpController.text,
      );
      setState(() => _isLoading = false);
      if (!result.isSuccess) {
        if (!mounted) return;
        if (kDebugMode) {
          final code = result.failureOrNull?.code;
          debugPrint('OTP verification failed: ${code ?? 'unknown'}');
        }
        _showSnackBar(
          _formatErrorMessage(
            localizations.otpVerificationFailed,
            result.failureOrNull?.message,
          ),
        );
        return;
      }

      if (!mounted) return;
      AppRouter.goToRole(context);
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      _showSnackBar(
        _formatErrorMessage(localizations.otpVerificationFailed, e.toString()),
      );
    }
  }

  void _startResendTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() => _resendTimer--);
      if (_resendTimer <= 0) {
        timer.cancel();
      }
    });
  }

  Future<void> _resendOTP() async {
    final localizations = AppLocalizations.of(context);

    if (!_isPhoneAuthSupported) {
      _showSnackBar(localizations.phoneAuthUnsupported);
      return;
    }

    if (_resendTimer > 0) return;

    setState(() {
      _isLoading = true;
      _resendTimer = AppConstants.otpResendSeconds;
    });

    try {
      final result = await AuthDependencies.verifyPhoneNumber().call(
        phoneNumber: _phoneController.text,
        onVerificationCompleted: (_) {
          if (!mounted) return;
          setState(() => _isLoading = false);
          AppRouter.goToRole(context);
        },
        onVerificationFailed: (failure) {
          if (!mounted) return;
          if (kDebugMode) {
            final code = failure.code;
            debugPrint('Resend OTP failed: ${code ?? 'unknown'}');
          }
          _showSnackBar(
            _formatErrorMessage(localizations.resendFailed, failure.message),
          );
          setState(() => _isLoading = false);
        },
        onCodeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          if (!mounted) return;
          setState(() => _isLoading = false);
          _startResendTimer();
          _showSnackBar(localizations.otpSentSuccess);
        },
        onCodeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
      if (!result.isSuccess) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        _showSnackBar(
          _formatErrorMessage(
            localizations.resendError,
            result.failureOrNull?.message,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      _showSnackBar(
        _formatErrorMessage(localizations.resendError, e.toString()),
      );
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _formatErrorMessage(String base, String? details) {
    if (!kDebugMode || details == null || details.trim().isEmpty) {
      return base;
    }
    return '$base: $details';
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = Responsive.isWideLayout(context);
            final content = isWide
                ? Row(
                    children: [
                      Expanded(child: _buildAuthHero(localizations)),
                      const SizedBox(width: 32),
                      Expanded(child: _buildAuthContent(localizations)),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildAuthHero(localizations, compact: true),
                      const SizedBox(height: 24),
                      _buildAuthContent(localizations),
                    ],
                  );

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: SizedBox(
                    width: isWide ? 960 : double.infinity,
                    child: content,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAuthContent(AppLocalizations localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          localizations.welcomeBack,
          style: AppTypography.h2.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.start,
        ),
        const SizedBox(height: 8),
        Text(
          localizations.authSubtitle,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 32),
        if (!_showPhoneAuth && !_showOTPVerification)
          ..._buildSocialAuth(localizations)
        else if (_showPhoneAuth && !_showOTPVerification)
          ..._buildPhoneAuth(localizations)
        else
          ..._buildOTPVerification(localizations),
      ],
    );
  }

  Widget _buildAuthHero(
    AppLocalizations localizations, {
    bool compact = false,
  }) {
    final height = compact ? 220.0 : 360.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: SizedBox(
        height: height,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/hero_auth.png',
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.black.withValues(alpha: 0.08),
                      AppColors.primary.withValues(alpha: 0.2),
                      AppColors.background.withValues(alpha: 0.1),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 24,
              right: 24,
              bottom: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.cta],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 28,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    localizations.welcomeToLuqta,
                    style: AppTypography.h2.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    localizations.authSubtitle,
                    style: AppTypography.bodyMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSocialAuth(AppLocalizations localizations) {
    return [
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.textSecondary.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: _isLoading ? null : _signInWithGoogle,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.textPrimary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: AppColors.divider),
            ),
          ),
          icon: const Icon(Icons.g_mobiledata, size: 24, color: Colors.red),
          label: Text(
            localizations.signInWithGoogle,
            style: AppTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),

      const SizedBox(height: 16),

      // Apple Sign In
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.textSecondary.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: _isLoading ? null : _signInWithApple,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.apple, size: 24),
          label: Text(
            localizations.signInWithApple,
            style: AppTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),

      const SizedBox(height: 24),

      // OR Divider
      Row(
        children: [
          const Expanded(child: Divider()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'أو',
              style: AppTypography.bodyMedium,
              textDirection: TextDirection.rtl,
            ),
          ),
          const Expanded(child: Divider()),
        ],
      ),

      const SizedBox(height: 24),

      if (_isPhoneAuthSupported)
        CTAButton(
          text: localizations.signInWithPhone,
          icon: Icons.phone,
          onPressed: _isLoading
              ? null
              : () {
                  setState(() {
                    _showPhoneAuth = true;
                    _showOTPVerification = false;
                  });
                },
        )
      else
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  localizations.phoneAuthSupportInfo,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
    ];
  }

  List<Widget> _buildPhoneAuth(AppLocalizations localizations) {
    return [
      Align(
        alignment: AlignmentDirectional.centerStart,
        child: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              _showPhoneAuth = false;
              _showOTPVerification = false;
              _phoneController.clear();
              _verificationId = null;
            });
          },
        ),
      ),
      const SizedBox(height: 4),
      AppTextField(
        controller: _phoneController,
        label: localizations.phoneNumber,
        hint: '+964 XXX XXX XXXX',
        prefixIcon: Icons.phone,
        keyboardType: TextInputType.phone,
        textInputAction: TextInputAction.done,
        enabled: !_isLoading,
        autofillHints: const [AutofillHints.telephoneNumber],
        onFieldSubmitted: (_) => _signInWithPhone(),
      ),

      const SizedBox(height: 24),

      PrimaryButton(
        text: _showOTPVerification ? localizations.verify : localizations.next,
        onPressed: _isLoading ? null : _signInWithPhone,
        isLoading: _isLoading,
      ),
    ];
  }

  List<Widget> _buildOTPVerification(AppLocalizations localizations) {
    return [
      // Back Button
      Align(
        alignment: AlignmentDirectional.centerStart,
        child: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              _showOTPVerification = false;
              _otpController.clear();
              _verificationId = null;
            });
          },
        ),
      ),

      const SizedBox(height: 16),

      // OTP Info
      Text(
        localizations.enterOTP,
        style: AppTypography.bodyMedium,
        textAlign: TextAlign.center,
      ),

      const SizedBox(height: 8),

      Text(
        _phoneController.text,
        style: AppTypography.h4.copyWith(color: AppColors.primary),
        textAlign: TextAlign.center,
      ),

      const SizedBox(height: 32),

      // OTP Input
      AppTextField(
        controller: _otpController,
        label: localizations.verifyOTP,
        hint: '000000',
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
        maxLength: AppConstants.otpLength,
        textAlign: TextAlign.center,
        textStyle: AppTypography.h2,
        autofillHints: const [AutofillHints.oneTimeCode],
        onFieldSubmitted: (_) => _verifyOTP(),
      ),

      const SizedBox(height: 24),

      // Verify Button
      PrimaryButton(
        text: localizations.verify,
        onPressed: _isLoading ? null : _verifyOTP,
        isLoading: _isLoading,
      ),

      const SizedBox(height: 16),

      // Resend OTP
      TextButton(
        onPressed: _resendTimer > 0 ? null : _resendOTP,
        child: Text(
          _resendTimer > 0
              ? '${localizations.resendCode} ($_resendTimer)'
              : localizations.resendCode,
        ),
      ),
    ];
  }
}
