import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:laqta/core/constants/app_constants.dart';
import 'package:laqta/core/localization/app_localizations.dart';
import 'package:laqta/app/router/app_router.dart';
import 'package:laqta/core/utils/responsive.dart';
import 'package:laqta/core/widgets/app_buttons.dart';
import 'package:laqta/core/widgets/iraqi_phone_number_field.dart';
import 'package:laqta/core/widgets/app_text_field.dart';
import 'package:laqta/features/auth/auth_dependencies.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

enum AuthMode { signIn, signUp }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  static Future<void>? _googleSignInInit;
  bool _isLoading = false;
  bool _showPhoneAuth = false; // Start with social auth options
  bool _showOTPVerification = false;
  late AuthMode _mode;
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  int _resendTimer = 0;
  String? _verificationId;
  Timer? _timer;
  bool _obscurePassword = true;

  bool get _isArabic =>
      Localizations.localeOf(context).languageCode.toLowerCase() == 'ar';

  String _tr({required String ar, required String en}) => _isArabic ? ar : en;

  @override
  void initState() {
    super.initState();
    const devAuthMode = String.fromEnvironment(
      'LAQTA_DEV_AUTH_MODE',
      defaultValue: '',
    );
    final normalized = devAuthMode.trim().toLowerCase();
    _mode = kDebugMode && (normalized == 'signup' || normalized == 'sign_up')
        ? AuthMode.signUp
        : AuthMode.signIn;
  }

  void _trackTap(String action) {
    if (kDebugMode) {
      debugPrint("AUTH_TAP:$action");
    }
  }

  bool get _isSignUp => _mode == AuthMode.signUp;

  void _handleBackFromPhone() {
    if (_isLoading) return;
    _timer?.cancel();
    _timer = null;
    setState(() {
      _showPhoneAuth = false;
      _showOTPVerification = false;
      _phoneController.clear();
      _otpController.clear();
      _resendTimer = 0;
      _verificationId = null;
    });
  }

  void _handleBackFromOTP() {
    if (_isLoading) return;
    setState(() {
      _showOTPVerification = false;
      _otpController.clear();
      _verificationId = null;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _identifierController.dispose();
    _passwordController.dispose();
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

  bool get _isAppleSignInSupported {
    if (kIsWeb) {
      return true;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return true;
      default:
        return false;
    }
  }

  Future<void> _ensureGoogleSignInInitialized() {
    return _googleSignInInit ??= GoogleSignIn.instance.initialize();
  }

  Future<void> _signInWithGoogle() async {
    _trackTap("google");
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
      AppRouter.goToProfileSetup(context);
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
    _trackTap("apple");
    final localizations = AppLocalizations.of(context);
    final isAvailable = await SignInWithApple.isAvailable();
    if (!isAvailable) {
      _showSnackBar(localizations.appleSignInUnavailable);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await AuthDependencies.signInWithApple().call();
      if (!result.isSuccess) {
        final failure = result.failureOrNull;
        if (failure?.code == 'canceled') {
          return;
        }
        if (!mounted) return;
        _showSnackBar(
          _formatErrorMessage(
            localizations.appleSignInFailed,
            failure?.message,
          ),
        );
        return;
      }
      if (!mounted) return;
      AppRouter.goToProfileSetup(context);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(
        _formatErrorMessage(localizations.appleSignInFailed, e.toString()),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signInWithPassword() async {
    _trackTap("password");
    final localizations = AppLocalizations.of(context);

    final identifier = _identifierController.text.trim();
    final password = _passwordController.text;

    if (identifier.isEmpty) {
      _showSnackBar(
        _tr(
          ar: 'يرجى إدخال اسم المستخدم أو البريد الإلكتروني',
          en: 'Please enter your username or email',
        ),
      );
      return;
    }
    if (password.isEmpty) {
      _showSnackBar(
        _tr(ar: 'يرجى إدخال كلمة المرور', en: 'Please enter your password'),
      );
      return;
    }

    final normalized = identifier.replaceAll(' ', '');
    final looksLikePhone = RegExp(r'^\+?\d{7,}$').hasMatch(normalized);
    if (looksLikePhone && !normalized.contains('@')) {
      _showSnackBar(
        _tr(
          ar: 'للدخول برقم الهاتف استخدم التحقق بالرمز (OTP)',
          en: 'Use phone verification (OTP) to sign in with a phone number',
        ),
      );
      setState(() {
        _showPhoneAuth = true;
        _showOTPVerification = false;
        _phoneController.text = identifier;
      });
      return;
    }

    final email = normalized.contains('@')
        ? normalized
        : '${normalized.toLowerCase()}@laqta.app';

    setState(() => _isLoading = true);

    try {
      final result = await AuthDependencies.signInWithPassword().call(
        email: email,
        password: password,
      );
      if (!result.isSuccess) {
        final failure = result.failureOrNull;
        if (kDebugMode) {
          debugPrint('Password sign-in failed: ${failure?.code ?? 'unknown'}');
        }
        _showSnackBar(
          _formatErrorMessage(
            localizations.somethingWentWrong,
            failure?.message,
          ),
        );
        return;
      }
      if (!mounted) return;
      AppRouter.goToProfileSetup(context);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(
        _formatErrorMessage(localizations.somethingWentWrong, e.toString()),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signInWithPhone() async {

    _trackTap("phone");
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
          AppRouter.goToProfileSetup(context);
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
    _trackTap("otp_verify");
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
      AppRouter.goToProfileSetup(context);
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
    _trackTap("otp_resend");
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
          AppRouter.goToProfileSetup(context);
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
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        showCloseIcon: true,
      ),
    );
  }

  void _setAuthMode(AuthMode mode) {
    if (_mode == mode) return;
    setState(() {
      _mode = mode;
      _showPhoneAuth = false;
      _showOTPVerification = false;
      _verificationId = null;
      _identifierController.clear();
      _passwordController.clear();
      _phoneController.clear();
      _otpController.clear();
    });
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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_isLoading) return;
        if (_showOTPVerification) {
          _handleBackFromOTP();
          return;
        }
        if (_showPhoneAuth) {
          _handleBackFromPhone();
          return;
        }

        // Auth is part of onboarding; go back to language selector instead of exiting.
        AppRouter.goToLanguage(context);
      },
      child: Scaffold(
        body: Stack(
          children: [
            const _AuthBackdrop(),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Center(
                        child: SizedBox(
                          width: Responsive.isWideLayout(context)
                              ? 520
                              : double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildHeader(localizations),
                              const SizedBox(height: 20),
                              _AuthGlassCard(
                                padding: const EdgeInsets.all(18),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    _buildModeToggle(localizations),
                                    const SizedBox(height: 20),
                                    _buildAuthContent(localizations),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_isLoading) const _AuthLoadingBarrier(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations localizations) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final title = _isSignUp
        ? localizations.signUpTitle
        : localizations.signInTitle;

    return Column(
      children: [
        Container(
          height: 72,
          width: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [scheme.primary, scheme.secondary],
            ),
            boxShadow: [
              BoxShadow(
                color: scheme.primary.withValues(alpha: 0.25),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.camera_alt, size: 32, color: Colors.white),
        ),
        const SizedBox(height: 16),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: Text(
            title,
            key: ValueKey(title),
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          localizations.authSubtitle,
          style: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildModeToggle(AppLocalizations localizations) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ModeChip(
              label: localizations.signInTitle,
              isActive: !_isSignUp,
              onTap: () => _setAuthMode(AuthMode.signIn),
              textTheme: textTheme,
              scheme: scheme,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _ModeChip(
              label: localizations.signUpTitle,
              isActive: _isSignUp,
              onTap: () {
                if (_isLoading) return;
                _setAuthMode(AuthMode.signIn);
                AppRouter.goToSignUpDetails(context);
              },
              textTheme: textTheme,
              scheme: scheme,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthContent(AppLocalizations localizations) {
    final contentKey = _showOTPVerification
        ? 'otp'
        : _showPhoneAuth
        ? 'phone'
        : 'social';

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        final slide =
            Tween<Offset>(
              begin: const Offset(0, 0.04),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            );

        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: slide, child: child),
        );
      },
      child: KeyedSubtree(
        key: ValueKey(contentKey),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!_showPhoneAuth && !_showOTPVerification)
              ..._buildSocialAuth(localizations)
            else if (_showPhoneAuth && !_showOTPVerification)
              ..._buildPhoneAuth(localizations)
            else
              ..._buildOTPVerification(localizations),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSocialAuth(AppLocalizations localizations) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    if (_isSignUp) {
      return [
        CTAButton(
          text: localizations.signUpTitle,
          icon: Icons.person_add_alt_1_rounded,
          onPressed: _isLoading
              ? null
              : () => AppRouter.goToSignUpDetails(context),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: Divider(
                color: scheme.outlineVariant.withValues(alpha: 0.7),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text(
                localizations.or,
                style: textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: scheme.outlineVariant.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        ..._buildProviderButtons(localizations),
      ];
    }

    return [
      AppTextField(
        controller: _identifierController,
        label: _tr(ar: 'اسم المستخدم / البريد الإلكتروني', en: 'Username / Email'),
        hint: _tr(ar: 'مثال: ahmedphoto23', en: 'Example: ahmedphoto23'),
        prefixIcon: Icons.person_outline,
        enabled: !_isLoading,
        textInputAction: TextInputAction.next,
      ),
      const SizedBox(height: 12),
      AppTextField(
        controller: _passwordController,
        label: _tr(ar: 'كلمة المرور', en: 'Password'),
        hint: '********',
        prefixIcon: Icons.lock_outline,
        enabled: !_isLoading,
        obscureText: _obscurePassword,
        suffixIcon: _obscurePassword
            ? Icons.visibility_outlined
            : Icons.visibility_off_outlined,
        onSuffixTap: () => setState(() => _obscurePassword = !_obscurePassword),
        textInputAction: TextInputAction.done,
        onFieldSubmitted: (_) => _signInWithPassword(),
      ),
      const SizedBox(height: 16),
      PrimaryButton(
        text: localizations.signInTitle,
        icon: Icons.login_rounded,
        onPressed: _isLoading ? null : _signInWithPassword,
        isLoading: _isLoading,
      ),
      const SizedBox(height: 18),
      Row(
        children: [
          Expanded(
            child: Divider(color: scheme.outlineVariant.withValues(alpha: 0.7)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              localizations.or,
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Divider(color: scheme.outlineVariant.withValues(alpha: 0.7)),
          ),
        ],
      ),
      const SizedBox(height: 18),
      ..._buildProviderButtons(localizations),
    ];
  }

  List<Widget> _buildProviderButtons(AppLocalizations localizations) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final googleLabel = _isSignUp
        ? localizations.signUpWithGoogle
        : localizations.signInWithGoogle;
    final appleLabel = _isSignUp
        ? localizations.signUpWithApple
        : localizations.signInWithApple;
    final phoneLabel = _isSignUp
        ? localizations.signUpWithPhone
        : localizations.signInWithPhone;

    return [
      _AuthProviderButton(
        onPressed: _isLoading ? null : _signInWithGoogle,
        backgroundColor: theme.brightness == Brightness.dark
            ? const Color(0xFFF8FAFC)
            : scheme.surface,
        foregroundColor: Colors.black,
        border: BorderSide(color: scheme.outlineVariant),
        icon: const _AuthBadge(
          backgroundColor: Colors.white,
          child: Icon(Icons.g_mobiledata_rounded, color: Color(0xFF4285F4)),
        ),
        label: googleLabel,
        textStyle: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
      ),

      const SizedBox(height: 14),

      if (_isAppleSignInSupported) ...[
        _AuthProviderButton(
          onPressed: _isLoading ? null : _signInWithApple,
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          icon: const _AuthBadge(
            backgroundColor: Colors.black,
            child: Icon(Icons.apple, color: Colors.white),
          ),
          label: appleLabel,
          textStyle: textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 18),
      ],

      if (_isPhoneAuthSupported)
        _AuthProviderButton(
          onPressed: _isLoading
              ? null
              : () {
                  _trackTap("phone_start");
                  setState(() {
                    _showPhoneAuth = true;
                    _showOTPVerification = false;
                  });
                },
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          icon: const _AuthBadge(
            backgroundColor: Colors.black,
            child: Icon(Icons.phone_iphone_rounded, color: Colors.white),
          ),
          label: phoneLabel,
          textStyle: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w800),
        )
      else
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: scheme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: scheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  localizations.phoneAuthSupportInfo,
                  style: textTheme.bodySmall?.copyWith(color: scheme.primary),
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
          onPressed: _handleBackFromPhone,
        ),
      ),
      const SizedBox(height: 4),
      IraqiPhoneNumberField(
        context: context,
        controller: _phoneController,
        label: localizations.phoneNumber,
        hint: '07XXXXXXXXX',
        enabled: !_isLoading,
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
          onPressed: _handleBackFromOTP,
        ),
      ),

      const SizedBox(height: 16),

      // OTP Info
      Text(
        localizations.enterOTP,
        style: Theme.of(context).textTheme.bodyMedium,
        textAlign: TextAlign.center,
      ),

      const SizedBox(height: 8),

      Text(
        _phoneController.text,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
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
        textStyle: Theme.of(context).textTheme.headlineSmall,
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

class _ModeChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final TextTheme textTheme;
  final ColorScheme scheme;

  const _ModeChip({
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.textTheme,
    required this.scheme,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isActive ? scheme.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: scheme.primary.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Center(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style:
                  textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isActive ? scheme.onPrimary : scheme.onSurface,
                  ) ??
                  TextStyle(
                    fontWeight: FontWeight.w700,
                    color: isActive ? scheme.onPrimary : scheme.onSurface,
                  ),
              child: Text(label),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthBackdrop extends StatelessWidget {
  const _AuthBackdrop();

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final base = brightness == Brightness.dark
        ? const Color(0xFF14110D)
        : const Color(0xFFF8F1E7);
    final mid = brightness == Brightness.dark
        ? const Color(0xFF1B1711)
        : const Color(0xFFF2E7DA);
    final coolGlow = brightness == Brightness.dark
        ? const Color(0xFF2A2E3A).withValues(alpha: 0.12)
        : const Color(0xFFF7EFE5).withValues(alpha: 0.45);
    final warmGlow = brightness == Brightness.dark
        ? const Color(0xFF8A5A2B).withValues(alpha: 0.25)
        : const Color(0xFFF1D8B5).withValues(alpha: 0.75);
    final roseGlow = brightness == Brightness.dark
        ? const Color(0xFF6E3D2B).withValues(alpha: 0.16)
        : const Color(0xFFF3E1CB).withValues(alpha: 0.6);

    return IgnorePointer(
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [base, mid, base],
                ),
              ),
            ),
          ),
          Positioned(
            top: -140,
            right: -80,
            child: _SoftGlow(size: 260, color: coolGlow),
          ),
          Positioned(
            bottom: -160,
            left: -90,
            child: _SoftGlow(size: 300, color: warmGlow),
          ),
          Positioned(
            top: 140,
            left: -120,
            child: _SoftGlow(size: 220, color: roseGlow),
          ),
        ],
      ),
    );
  }
}

class _SoftGlow extends StatelessWidget {
  final double size;
  final Color color;

  const _SoftGlow({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
      ),
    );
  }
}

class _AuthGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _AuthGlassCard({
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;

    final borderColor = brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.12)
        : scheme.outlineVariant.withValues(alpha: 0.7);
    final gradientStart = brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.07)
        : Colors.white.withValues(alpha: 0.95);
    final gradientEnd = brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.04)
        : Colors.white.withValues(alpha: 0.8);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.32),
            blurRadius: 32,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: borderColor, width: 1),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [gradientStart, gradientEnd],
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _AuthProviderButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color foregroundColor;
  final BorderSide? border;
  final Widget icon;
  final String label;
  final TextStyle? textStyle;

  const _AuthProviderButton({
    required this.onPressed,
    required this.backgroundColor,
    required this.foregroundColor,
    this.border,
    required this.icon,
    required this.label,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final effectiveBorder = border ?? BorderSide(color: scheme.outlineVariant);
    final effectiveForeground = onPressed == null
        ? foregroundColor.withValues(alpha: 0.55)
        : foregroundColor;
    final resolvedTextStyle =
        (textStyle ?? Theme.of(context).textTheme.bodyLarge)?.copyWith(
          color: effectiveForeground,
        );

    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: effectiveForeground,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: effectiveBorder,
          ),
        ),
        child: Row(
          children: [
            icon,
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: resolvedTextStyle,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 36),
          ],
        ),
      ),
    );
  }
}

class _AuthBadge extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;

  const _AuthBadge({required this.child, required this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      width: 32,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Center(child: child),
    );
  }
}

class _AuthLoadingBarrier extends StatelessWidget {
  const _AuthLoadingBarrier();

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Positioned.fill(
      child: Stack(
        children: [
          const ModalBarrier(dismissible: false, color: Color(0x66000000)),
          Center(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: scheme.surface.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: scheme.outlineVariant.withValues(alpha: 0.7),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          scheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      localizations.loading,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

