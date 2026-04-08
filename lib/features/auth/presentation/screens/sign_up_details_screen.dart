import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:laqta/core/constants/app_constants.dart';
import 'package:laqta/core/localization/app_localizations.dart';
import 'package:laqta/app/router/app_router.dart';
import 'package:laqta/core/utils/debouncer.dart';
import 'package:laqta/core/widgets/app_buttons.dart';
import 'package:laqta/core/widgets/iraqi_phone_number_field.dart';
import 'package:laqta/core/widgets/app_text_field.dart';
import 'package:laqta/features/auth/auth_dependencies.dart';
import 'package:laqta/features/profile/domain/entities/user_profile_update.dart';
import 'package:laqta/features/profile/profile_dependencies.dart';

class SignUpDetailsScreen extends StatefulWidget {
  const SignUpDetailsScreen({super.key});

  @override
  State<SignUpDetailsScreen> createState() => _SignUpDetailsScreenState();
}

class _SignUpDetailsScreenState extends State<SignUpDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _birthYearController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final Debouncer _usernameDebouncer = Debouncer(
    delay: const Duration(milliseconds: 450),
  );

  static const String _usernameEmailDomain = 'laqta.app';
  static const Set<String> _reservedUsernames = {
    'admin',
    'support',
    'system',
    'root',
    'owner',
    'official',
    'laqta',
    'photographer',
    'customer',
    'help',
    'service',
    'staff',
    'admin1',
    'mod',
    'moderator',
  };

  String? _selectedRole;
  String? _selectedGender;
  String? _selectedGovernorate;
  bool _over18Confirmed = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  bool _isCheckingUsername = false;
  bool _usernameAvailable = false;
  String? _usernameError;

  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _birthYearController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameDebouncer.dispose();
    super.dispose();
  }

  bool _isUsernameForbidden(String username) {
    if (_reservedUsernames.contains(username)) return true;
    if (username.startsWith('admin')) return true;
    if (username.startsWith('support')) return true;
    if (username.startsWith('system')) return true;
    return false;
  }

  bool _isUsernameFormatValid(String username) {
    final regex = RegExp(r'^[a-z][a-z0-9]*$');
    return regex.hasMatch(username) && username.length >= 2;
  }

  Future<void> _checkUsernameAvailability(String rawUsername) async {
    final username = rawUsername.trim().toLowerCase();
    if (username.length < 2) {
      setState(() {
        _isCheckingUsername = false;
        _usernameAvailable = false;
        _usernameError = null;
      });
      return;
    }

    if (_isUsernameForbidden(username)) {
      setState(() {
        _isCheckingUsername = false;
        _usernameAvailable = false;
        _usernameError = 'اسم المستخدم محجوز';
      });
      return;
    }

    if (!_isUsernameFormatValid(username)) {
      setState(() {
        _isCheckingUsername = false;
        _usernameAvailable = false;
        _usernameError =
            'يجب أن يبدأ بحرف ويحتوي على حروف أو أرقام فقط بدون مسافات';
      });
      return;
    }

    setState(() => _isCheckingUsername = true);

    try {
      final result = await ProfileDependencies.checkUsernameAvailability().call(
        username,
      );
      if (!result.isSuccess) {
        throw StateError(result.failureOrNull?.message ?? 'Check failed');
      }
      setState(() {
        _isCheckingUsername = false;
        _usernameAvailable = result.valueOrNull ?? false;
        _usernameError = _usernameAvailable ? null : 'اسم المستخدم غير متاح';
      });
    } catch (e) {
      setState(() {
        _isCheckingUsername = false;
        _usernameAvailable = false;
        _usernameError = 'تعذر التحقق من اسم المستخدم';
      });
    }
  }

  String _emailForUsername(String usernameLower) {
    return '$usernameLower@$_usernameEmailDomain';
  }

  Future<void> _submit() async {
    final localizations = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final role = (_selectedRole ?? '').trim();
    if (role.isEmpty) {
      messenger.showSnackBar(SnackBar(content: Text(localizations.chooseRole)));
      return;
    }

    if (!_formKey.currentState!.validate()) return;
    if (_usernameError != null && _usernameError!.isNotEmpty) {
      messenger.showSnackBar(SnackBar(content: Text(_usernameError!)));
      return;
    }
    if (_selectedGender == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('اختر نوع الجنس من فضلك')),
      );
      return;
    }
    if (_selectedGovernorate == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('اختر المحافظة من فضلك')),
      );
      return;
    }
    if (!_over18Confirmed) {
      messenger.showSnackBar(
        const SnackBar(content: Text('يجب تأكيد أنك فوق 18 سنة')),
      );
      return;
    }

    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;
    if (password.length < 6) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('كلمة المرور يجب أن تكون 6 أحرف على الأقل'),
        ),
      );
      return;
    }
    if (password != confirm) {
      messenger.showSnackBar(
        const SnackBar(content: Text('تأكيد كلمة المرور غير مطابق')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final usernameLower = _usernameController.text.trim().toLowerCase();
      final emailForAuth = _emailForUsername(usernameLower);

      final signUpResult = await AuthDependencies.signUpWithPassword().call(
        email: emailForAuth,
        password: password,
      );
      if (!signUpResult.isSuccess) {
        final failure = signUpResult.failureOrNull;
        if (kDebugMode) {
          debugPrint('Password sign-up failed: ${failure?.code}');
        }
        messenger.showSnackBar(
          SnackBar(
            content: Text(failure?.message ?? localizations.somethingWentWrong),
          ),
        );
        return;
      }

      final authUserId = signUpResult.valueOrNull?.id;
      if (authUserId == null || authUserId.isEmpty) {
        throw StateError('Missing auth user id after sign-up');
      }

      final birthYear = int.tryParse(_birthYearController.text.trim());
      final age = birthYear != null ? DateTime.now().year - birthYear : null;

      final data = BasicInfoData(
        role: role,
        name: _fullNameController.text.trim(),
        username: usernameLower,
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        governorate: _selectedGovernorate!,
        gender: _selectedGender,
        birthYear: birthYear,
        age: age,
        over18Confirmed: _over18Confirmed,
        profileCompleted: true,
      );

      final saveResult = await ProfileDependencies.saveBasicInfo().call(
        userId: authUserId,
        data: data,
      );
      if (!saveResult.isSuccess) {
        final rollback = await AuthDependencies.deleteCurrentUser().call();
        if (kDebugMode && !rollback.isSuccess) {
          debugPrint(
            'Failed to rollback auth user after sign-up save failure: '
            '${rollback.failureOrNull}',
          );
        }
        throw StateError(
          saveResult.failureOrNull?.message ?? 'Save failed',
        );
      }

      AppRouter.invalidateProfileCache(authUserId);
      if (!mounted) return;
      AppRouter.goToHome(context);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Sign-up flow failed: $e');
      }
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              e is StateError
                  ? e.message.toString()
                  : localizations.somethingWentWrong,
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final governorates = AppConstants.iraqiGovernoratesAr;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_isLoading) return;
        AppRouter.goToAuth(context);
      },
      child: Scaffold(
        body: Stack(
          children: [
            const _AuthBackdrop(),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: _AuthGlassCard(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  onPressed: _isLoading
                                      ? null
                                      : () => AppRouter.goToAuth(context),
                                  icon: const Icon(Icons.arrow_back),
                                ),
                                const Spacer(),
                                Text(
                                  localizations.signUpTitle,
                                  style: textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const Spacer(),
                                const SizedBox(width: 48),
                              ],
                            ),
                            const SizedBox(height: 12),

                            Text(
                              localizations.chooseRole,
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: _OptionCard(
                                    icon: Icons.person,
                                    label: localizations.customer,
                                    isSelected:
                                        _selectedRole ==
                                        AppConstants.roleCustomer,
                                    onTap: () => setState(
                                      () => _selectedRole =
                                          AppConstants.roleCustomer,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _OptionCard(
                                    icon: Icons.camera_alt,
                                    label: localizations.photographer,
                                    isSelected:
                                        _selectedRole ==
                                        AppConstants.rolePhotographer,
                                    onTap: () => setState(
                                      () => _selectedRole =
                                          AppConstants.rolePhotographer,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 22),
                            AppTextField(
                              controller: _fullNameController,
                              label: localizations.fullName,
                              hint: 'مثال: أحمد محمد',
                              prefixIcon: Icons.badge_outlined,
                              enabled: !_isLoading,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'الرجاء إدخال الاسم';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),
                            AppTextField(
                              controller: _usernameController,
                              label: 'اسم المستخدم',
                              hint: 'مثال: ahmedphoto23',
                              prefixIcon: Icons.person_outline,
                              enabled: !_isLoading,
                              suffixIcon: _isCheckingUsername
                                  ? null
                                  : _usernameAvailable
                                  ? Icons.check_circle
                                  : null,
                              onChanged: (value) {
                                final normalized = value.trim().toLowerCase();
                                if (normalized != value) {
                                  _usernameController
                                    ..text = normalized
                                    ..selection = TextSelection.collapsed(
                                      offset: normalized.length,
                                    );
                                }
                                setState(() => _usernameError = null);
                                _usernameDebouncer(
                                  () => _checkUsernameAvailability(normalized),
                                );
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'الرجاء إدخال اسم المستخدم';
                                }
                                final normalized = value.trim().toLowerCase();
                                if (_isUsernameForbidden(normalized)) {
                                  return 'اسم المستخدم محجوز';
                                }
                                if (!_isUsernameFormatValid(normalized)) {
                                  return 'يجب أن يبدأ بحرف ويحتوي على حروف أو أرقام فقط';
                                }
                                if (!_usernameAvailable &&
                                    !_isCheckingUsername) {
                                  return 'اسم المستخدم غير متاح';
                                }
                                if (_usernameError != null &&
                                    _usernameError!.isNotEmpty) {
                                  return _usernameError;
                                }
                                return null;
                              },
                            ),
                            if (_isCheckingUsername)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  'جارٍ التحقق...',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                              ),

                            const SizedBox(height: 16),
                            IraqiPhoneNumberField(
                              context: context,
                              controller: _phoneController,
                              label: localizations.phoneNumber,
                              hint: '07XXXXXXXXX',
                              enabled: !_isLoading,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return localizations.phoneNumberRequired;
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),
                            AppTextField(
                              controller: _emailController,
                              label: 'البريد الإلكتروني (اختياري)',
                              hint: 'example@email.com',
                              prefixIcon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              enabled: !_isLoading,
                            ),

                            const SizedBox(height: 16),
                            AppTextField(
                              controller: _birthYearController,
                              label: 'سنة الميلاد',
                              hint: 'مثال: 1995',
                              prefixIcon: Icons.cake_outlined,
                              keyboardType: TextInputType.number,
                              enabled: !_isLoading,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'الرجاء إدخال سنة الميلاد';
                                }
                                final year = int.tryParse(value);
                                if (year == null ||
                                    year < 1900 ||
                                    year > DateTime.now().year - 18) {
                                  return 'يجب أن تشير سنة الميلاد إلى عمر 18+';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 18),
                            Text(
                              localizations.governorate,
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            AppDropdownField<String>(
                              initialValue: _selectedGovernorate,
                              hint: localizations.selectGovernorate,
                              prefixIcon: Icons.location_on_outlined,
                              items: governorates.map((gov) {
                                return DropdownMenuItem(
                                  value: gov,
                                  child: Text(gov),
                                );
                              }).toList(),
                              onChanged: _isLoading
                                  ? null
                                  : (value) => setState(
                                      () => _selectedGovernorate = value,
                                    ),
                            ),

                            const SizedBox(height: 18),
                            Text(
                              'نوع الجنس',
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: _OptionCard(
                                    icon: Icons.male,
                                    label: localizations.male,
                                    isSelected: _selectedGender == 'male',
                                    onTap: () => setState(
                                      () => _selectedGender = 'male',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _OptionCard(
                                    icon: Icons.female,
                                    label: localizations.female,
                                    isSelected: _selectedGender == 'female',
                                    onTap: () => setState(
                                      () => _selectedGender = 'female',
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 18),
                            AppTextField(
                              controller: _passwordController,
                              label: 'كلمة المرور',
                              hint: '********',
                              prefixIcon: Icons.lock_outline,
                              enabled: !_isLoading,
                              obscureText: _obscurePassword,
                              suffixIcon: _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              onSuffixTap: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'الرجاء إدخال كلمة المرور';
                                }
                                if (value.length < 6) {
                                  return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),
                            AppTextField(
                              controller: _confirmPasswordController,
                              label: 'تأكيد كلمة المرور',
                              hint: '********',
                              prefixIcon: Icons.lock_outline,
                              enabled: !_isLoading,
                              obscureText: _obscureConfirmPassword,
                              suffixIcon: _obscureConfirmPassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              onSuffixTap: () => setState(
                                () => _obscureConfirmPassword =
                                    !_obscureConfirmPassword,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'الرجاء تأكيد كلمة المرور';
                                }
                                if (value != _passwordController.text) {
                                  return 'كلمتا المرور غير متطابقتين';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 18),
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: scheme.primary.withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: scheme.primary.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: _over18Confirmed,
                                    onChanged: _isLoading
                                        ? null
                                        : (value) => setState(
                                            () => _over18Confirmed =
                                                value ?? false,
                                          ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Expanded(
                                    child: Text(
                                      'أؤكد أن عمري فوق 18 سنة',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),
                            CTAButton(
                              text: localizations.signUpTitle,
                              onPressed: _isLoading ? null : _submit,
                              isLoading: _isLoading,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (_isLoading)
              Positioned.fill(
                child: ColoredBox(
                  color: Colors.black.withValues(alpha: 0.18),
                  child: const Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionCard({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? scheme.primary.withValues(alpha: 0.1)
              : scheme.surface,
          border: Border.all(
            color: isSelected ? scheme.primary : scheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 34,
              color: isSelected ? scheme.primary : scheme.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                color: isSelected ? scheme.primary : scheme.onSurface,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ],
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

  const _AuthGlassCard({required this.child});

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
            padding: const EdgeInsets.all(18),
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
