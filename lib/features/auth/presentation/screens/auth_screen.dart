import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:laqta/app/router/app_router.dart';
import 'package:laqta/core/constants/app_constants.dart';
import 'package:laqta/features/auth/auth_dependencies.dart';

enum _AuthMode { login, register, forgotPassword }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _loginIdentifierController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _forgotPhoneController = TextEditingController();
  final _forgotOtpController = TextEditingController();
  final _forgotPasswordController = TextEditingController();
  final _forgotConfirmPasswordController = TextEditingController();

  _AuthMode _mode = _AuthMode.login;
  int _step = 0;
  bool _isLoading = false;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  bool _forgotPasswordVisible = false;
  bool _forgotConfirmPasswordVisible = false;
  String _selectedRole = 'customer';
  String? _selectedGender;
  DateTime? _birthdate;
  String? _selectedProvince;
  String? _registrationRequestId;
  String? _forgotRequestId;
  int _registrationResendSeconds = 0;
  int _forgotResendSeconds = 0;
  Timer? _registrationTimer;
  Timer? _forgotTimer;

  static const _roleOptions = <_RoleOption>[
    _RoleOption('customer', 'عميل', Icons.person_outline_rounded),
    _RoleOption('photographer', 'مصور', Icons.photo_camera_outlined),
    _RoleOption('venue_owner', 'صاحب قاعة', Icons.apartment_rounded),
  ];

  static const _provinceOptions = <_ProvinceOption>[
    _ProvinceOption('baghdad', 'بغداد'),
    _ProvinceOption('basra', 'البصرة'),
    _ProvinceOption('nineveh', 'نينوى'),
    _ProvinceOption('erbil', 'أربيل'),
    _ProvinceOption('najaf', 'النجف'),
    _ProvinceOption('karbala', 'كربلاء'),
    _ProvinceOption('kirkuk', 'كركوك'),
    _ProvinceOption('dhi_qar', 'ذي قار'),
    _ProvinceOption('sulaymaniyah', 'السليمانية'),
    _ProvinceOption('anbar', 'الأنبار'),
    _ProvinceOption('diyala', 'ديالى'),
    _ProvinceOption('saladin', 'صلاح الدين'),
    _ProvinceOption('maysan', 'ميسان'),
    _ProvinceOption('wasit', 'واسط'),
    _ProvinceOption('muthanna', 'المثنى'),
    _ProvinceOption('qadisiyah', 'القادسية'),
    _ProvinceOption('babil', 'بابل'),
    _ProvinceOption('duhok', 'دهوك'),
  ];

  @override
  void dispose() {
    _registrationTimer?.cancel();
    _forgotTimer?.cancel();
    _loginIdentifierController.dispose();
    _loginPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _forgotPhoneController.dispose();
    _forgotOtpController.dispose();
    _forgotPasswordController.dispose();
    _forgotConfirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            const _AuthBackdrop(),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: _AuthGlassCard(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: _buildModeContent(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (_isLoading) const _AuthLoadingBarrier(),
          ],
        ),
      ),
    );
  }

  Widget _buildModeContent() {
    switch (_mode) {
      case _AuthMode.login:
        return _buildLogin();
      case _AuthMode.register:
        return _buildRegister();
      case _AuthMode.forgotPassword:
        return _buildForgotPassword();
    }
  }

  Widget _buildLogin() {
    return Column(
      key: const ValueKey('login'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const _AuthHeader(
          title: 'مرحباً بك في LAQTA',
          subtitle: 'سجّل الدخول للوصول إلى حسابك',
        ),
        const SizedBox(height: 28),
        _LabeledField(
          controller: _loginIdentifierController,
          label: 'رقم الهاتف أو اسم المستخدم',
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 14),
        _LabeledField(
          controller: _loginPasswordController,
          label: 'كلمة المرور',
          obscureText: !_passwordVisible,
          suffixIcon: IconButton(
            onPressed: () =>
                setState(() => _passwordVisible = !_passwordVisible),
            icon: Icon(
              _passwordVisible
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
            ),
          ),
          onSubmitted: (_) => _login(),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _isLoading
                ? null
                : () => setState(() => _mode = _AuthMode.forgotPassword),
            child: const Text('نسيت كلمة المرور؟'),
          ),
        ),
        const SizedBox(height: 12),
        _PrimaryActionButton(
          label: 'تسجيل الدخول',
          onPressed: _isLoading ? null : _login,
        ),
        const SizedBox(height: 18),
        _SwitchModeButton(
          prompt: 'ليس لديك حساب؟',
          action: 'إنشاء حساب',
          onPressed: _isLoading
              ? null
              : () => setState(() {
                  _mode = _AuthMode.register;
                  _step = 0;
                }),
        ),
      ],
    );
  }

  Widget _buildRegister() {
    return Column(
      key: ValueKey('register_$_step'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const _AuthHeader(
          title: 'مرحباً بك في LAQTA',
          subtitle: 'أنشئ حسابك بخطوات قصيرة وآمنة',
        ),
        const SizedBox(height: 18),
        _StepProgress(currentStep: _step + 1, totalSteps: 4),
        const SizedBox(height: 24),
        _buildRegisterStep(),
        const SizedBox(height: 24),
        Row(
          children: [
            if (_step > 0)
              Expanded(
                child: _SecondaryActionButton(
                  label: 'رجوع',
                  onPressed: _isLoading ? null : () => setState(() => _step--),
                ),
              ),
            if (_step > 0) const SizedBox(width: 12),
            Expanded(
              child: _PrimaryActionButton(
                label: _step == 3 ? 'إنشاء الحساب' : 'التالي',
                onPressed: _isLoading ? null : _nextRegistrationStep,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        _SwitchModeButton(
          prompt: 'لديك حساب؟',
          action: 'تسجيل الدخول',
          onPressed: _isLoading
              ? null
              : () => setState(() {
                  _mode = _AuthMode.login;
                  _step = 0;
                }),
        ),
      ],
    );
  }

  Widget _buildRegisterStep() {
    switch (_step) {
      case 0:
        return _buildRoleStep();
      case 1:
        return _buildBasicInfoStep();
      case 2:
        return _buildPersonalDetailsStep();
      case 3:
      default:
        return _buildPhonePasswordStep();
    }
  }

  Widget _buildRoleStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionTitle('اختر نوع الحساب'),
        const SizedBox(height: 12),
        for (final option in _roleOptions) ...[
          _ChoiceCard(
            selected: _selectedRole == option.value,
            icon: option.icon,
            label: option.label,
            onTap: () => setState(() => _selectedRole = option.value),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  Widget _buildBasicInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionTitle('المعلومات الأساسية'),
        const SizedBox(height: 12),
        _LabeledField(
          controller: _firstNameController,
          label: 'الاسم الأول',
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 12),
        _LabeledField(
          controller: _lastNameController,
          label: 'اسم العائلة',
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 12),
        _LabeledField(
          controller: _usernameController,
          label: 'اسم المستخدم',
          hint: 'مثال: ali.photography',
          textDirection: TextDirection.ltr,
          inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
        ),
      ],
    );
  }

  Widget _buildPersonalDetailsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionTitle('المعلومات الشخصية'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ChoiceCard(
                selected: _selectedGender == 'male',
                icon: Icons.male_rounded,
                label: 'ذكر',
                onTap: () => setState(() => _selectedGender = 'male'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ChoiceCard(
                selected: _selectedGender == 'female',
                icon: Icons.female_rounded,
                label: 'أنثى',
                onTap: () => setState(() => _selectedGender = 'female'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _PickerTile(
          label: 'تاريخ الميلاد',
          value: _birthdate == null
              ? 'اختر تاريخ الميلاد'
              : DateFormat('yyyy-MM-dd').format(_birthdate!),
          icon: Icons.calendar_month_outlined,
          onTap: _pickBirthdate,
        ),
        const SizedBox(height: 12),
        _DropdownTile(
          label: 'المحافظة',
          value: _selectedProvince,
          items: _provinceOptions,
          onChanged: (value) => setState(() => _selectedProvince = value),
        ),
      ],
    );
  }

  Widget _buildPhonePasswordStep() {
    final otpSent = _registrationRequestId != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionTitle('التحقق من الهاتف'),
        const SizedBox(height: 12),
        _LabeledField(
          controller: _phoneController,
          label: 'رقم الهاتف',
          hint: '077xxxxxxxx',
          keyboardType: TextInputType.phone,
          textDirection: TextDirection.ltr,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s]')),
          ],
        ),
        const SizedBox(height: 10),
        _SecondaryActionButton(
          label: _registrationResendSeconds > 0
              ? 'إعادة الإرسال خلال $_registrationResendSeconds ثانية'
              : 'إرسال رمز التحقق عبر SMS',
          onPressed: _isLoading || _registrationResendSeconds > 0
              ? null
              : _sendRegistrationOtp,
        ),
        if (otpSent) ...[
          const SizedBox(height: 12),
          _InfoText('تم إرسال رمز التحقق عبر رسالة SMS'),
          const SizedBox(height: 12),
          _LabeledField(
            controller: _otpController,
            label: 'أدخل رمز التحقق',
            keyboardType: TextInputType.number,
            textDirection: TextDirection.ltr,
            maxLength: AppConstants.otpLength,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
        ],
        const SizedBox(height: 12),
        _LabeledField(
          controller: _passwordController,
          label: 'كلمة المرور',
          obscureText: !_passwordVisible,
          suffixIcon: IconButton(
            onPressed: () =>
                setState(() => _passwordVisible = !_passwordVisible),
            icon: Icon(
              _passwordVisible
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
            ),
          ),
        ),
        const SizedBox(height: 12),
        _LabeledField(
          controller: _confirmPasswordController,
          label: 'تأكيد كلمة المرور',
          obscureText: !_confirmPasswordVisible,
          suffixIcon: IconButton(
            onPressed: () => setState(
              () => _confirmPasswordVisible = !_confirmPasswordVisible,
            ),
            icon: Icon(
              _confirmPasswordVisible
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForgotPassword() {
    final otpSent = _forgotRequestId != null;
    return Column(
      key: const ValueKey('forgot'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const _AuthHeader(
          title: 'نسيت كلمة المرور',
          subtitle: 'سنرسل رمز تحقق برسالة SMS لإعادة تعيينها',
        ),
        const SizedBox(height: 24),
        _LabeledField(
          controller: _forgotPhoneController,
          label: 'رقم الهاتف',
          hint: '077xxxxxxxx',
          keyboardType: TextInputType.phone,
          textDirection: TextDirection.ltr,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s]')),
          ],
        ),
        const SizedBox(height: 10),
        _SecondaryActionButton(
          label: _forgotResendSeconds > 0
              ? 'إعادة الإرسال خلال $_forgotResendSeconds ثانية'
              : 'إرسال رمز التحقق عبر SMS',
          onPressed: _isLoading || _forgotResendSeconds > 0
              ? null
              : _sendForgotOtp,
        ),
        if (otpSent) ...[
          const SizedBox(height: 12),
          _InfoText('تم إرسال رمز التحقق عبر رسالة SMS'),
          const SizedBox(height: 12),
          _LabeledField(
            controller: _forgotOtpController,
            label: 'أدخل رمز التحقق',
            keyboardType: TextInputType.number,
            textDirection: TextDirection.ltr,
            maxLength: AppConstants.otpLength,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: 12),
          _LabeledField(
            controller: _forgotPasswordController,
            label: 'كلمة المرور الجديدة',
            obscureText: !_forgotPasswordVisible,
            suffixIcon: IconButton(
              onPressed: () => setState(
                () => _forgotPasswordVisible = !_forgotPasswordVisible,
              ),
              icon: Icon(
                _forgotPasswordVisible
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _LabeledField(
            controller: _forgotConfirmPasswordController,
            label: 'تأكيد كلمة المرور',
            obscureText: !_forgotConfirmPasswordVisible,
            suffixIcon: IconButton(
              onPressed: () => setState(
                () => _forgotConfirmPasswordVisible =
                    !_forgotConfirmPasswordVisible,
              ),
              icon: Icon(
                _forgotConfirmPasswordVisible
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
            ),
          ),
        ],
        const SizedBox(height: 22),
        _PrimaryActionButton(
          label: 'تعيين كلمة المرور',
          onPressed: _isLoading || !otpSent ? null : _resetPassword,
        ),
        const SizedBox(height: 18),
        _SwitchModeButton(
          prompt: 'تذكرت كلمة المرور؟',
          action: 'تسجيل الدخول',
          onPressed: _isLoading
              ? null
              : () => setState(() => _mode = _AuthMode.login),
        ),
      ],
    );
  }

  Future<void> _login() async {
    final identifier = _loginIdentifierController.text.trim();
    final password = _loginPasswordController.text;
    if (identifier.isEmpty || password.isEmpty) {
      _showSnackBar('يرجى إدخال رقم الهاتف أو اسم المستخدم وكلمة المرور');
      return;
    }
    await _runAuthAction(() async {
      final result = await AuthDependencies.signInWithPassword().call(
        identifier: identifier,
        password: password,
      );
      if (!result.isSuccess) {
        throw _AuthUiException('بيانات الدخول غير صحيحة');
      }
      if (!mounted) return;
      AppRouter.goToHome(context);
    });
  }

  Future<void> _nextRegistrationStep() async {
    if (_step == 0) {
      setState(() => _step = 1);
      return;
    }
    if (_step == 1 && !_validateBasicInfo()) return;
    if (_step == 2 && !_validatePersonalDetails()) return;
    if (_step < 3) {
      setState(() => _step++);
      return;
    }
    await _completeRegistration();
  }

  bool _validateBasicInfo() {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final username = _usernameController.text.trim().toLowerCase();
    if (firstName.isEmpty) {
      _showSnackBar('الاسم الأول مطلوب');
      return false;
    }
    if (lastName.isEmpty) {
      _showSnackBar('اسم العائلة مطلوب');
      return false;
    }
    if (username.length < 3 || username.length > 30) {
      _showSnackBar('اسم المستخدم يجب أن يكون بين 3 و30 حرفاً');
      return false;
    }
    if (username.contains(RegExp(r'\s'))) {
      _showSnackBar('اسم المستخدم لا يجب أن يحتوي على مسافات');
      return false;
    }
    if (!RegExp(r'^[\u0600-\u06FFA-Za-z0-9_.]+$').hasMatch(username)) {
      _showSnackBar('اسم المستخدم يحتوي على أحرف غير مسموحة');
      return false;
    }
    _usernameController.text = username;
    return true;
  }

  bool _validatePersonalDetails() {
    if (_selectedGender == null) {
      _showSnackBar('يرجى اختيار الجنس');
      return false;
    }
    if (_birthdate == null) {
      _showSnackBar('يرجى اختيار تاريخ الميلاد');
      return false;
    }
    if (!_isAdult(_birthdate!)) {
      _showSnackBar('عذراً، يجب أن يكون عمرك 18 سنة أو أكثر لاستخدام LAQTA.');
      return false;
    }
    if (_selectedProvince == null) {
      _showSnackBar('يرجى اختيار المحافظة');
      return false;
    }
    return true;
  }

  bool _validatePhonePassword({required bool requireOtp}) {
    if (_phoneController.text.trim().isEmpty) {
      _showSnackBar('رقم الهاتف غير صحيح');
      return false;
    }
    if (requireOtp &&
        _otpController.text.trim().length != AppConstants.otpLength) {
      _showSnackBar('أدخل رمز التحقق');
      return false;
    }
    final password = _passwordController.text;
    if (!_isValidPassword(password)) {
      _showSnackBar('كلمة المرور يجب أن تكون 8 أحرف وتحتوي حرفاً ورقماً');
      return false;
    }
    if (password != _confirmPasswordController.text) {
      _showSnackBar('كلمة المرور غير متطابقة');
      return false;
    }
    return true;
  }

  Future<void> _sendRegistrationOtp() async {
    if (!_validateBasicInfo() || !_validatePersonalDetails()) return;
    if (_phoneController.text.trim().isEmpty) {
      _showSnackBar('رقم الهاتف غير صحيح');
      return;
    }
    await _runAuthAction(() async {
      final result = await AuthDependencies.startRegistration().call(
        role: _selectedRole,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        username: _usernameController.text.trim().toLowerCase(),
        gender: _selectedGender!,
        birthdate: DateFormat('yyyy-MM-dd').format(_birthdate!),
        province: _selectedProvince!,
        phone: _phoneController.text.trim(),
      );
      if (!result.isSuccess || result.valueOrNull == null) {
        throw _AuthUiException(
          _mapFailureMessage(result.failureOrNull?.message),
        );
      }
      final otp = result.valueOrNull!;
      setState(() {
        _registrationRequestId = otp.requestId;
        _registrationResendSeconds = otp.resendAfterSeconds;
      });
      _startRegistrationTimer();
      _showSnackBar('تم إرسال رمز التحقق عبر رسالة SMS');
    });
  }

  Future<void> _completeRegistration() async {
    if (_registrationRequestId == null) {
      _showSnackBar('أرسل رمز التحقق عبر SMS أولاً');
      return;
    }
    if (!_validatePhonePassword(requireOtp: true)) return;
    await _runAuthAction(() async {
      final result = await AuthDependencies.completeRegistration().call(
        requestId: _registrationRequestId!,
        code: _otpController.text.trim(),
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
      );
      if (!result.isSuccess) {
        throw _AuthUiException(
          _mapFailureMessage(result.failureOrNull?.message),
        );
      }
      if (!mounted) return;
      AppRouter.goToHome(context);
    });
  }

  Future<void> _sendForgotOtp() async {
    if (_forgotPhoneController.text.trim().isEmpty) {
      _showSnackBar('رقم الهاتف غير صحيح');
      return;
    }
    await _runAuthAction(() async {
      final result = await AuthDependencies.forgotPassword().call(
        phone: _forgotPhoneController.text.trim(),
      );
      if (!result.isSuccess || result.valueOrNull == null) {
        throw _AuthUiException('تعذر إرسال رمز التحقق عبر SMS');
      }
      final otp = result.valueOrNull!;
      setState(() {
        _forgotRequestId = otp.requestId;
        _forgotResendSeconds = otp.resendAfterSeconds;
      });
      _startForgotTimer();
      _showSnackBar('تم إرسال رمز التحقق عبر رسالة SMS');
    });
  }

  Future<void> _resetPassword() async {
    if (_forgotRequestId == null) {
      _showSnackBar('أرسل رمز التحقق عبر SMS أولاً');
      return;
    }
    if (_forgotOtpController.text.trim().length != AppConstants.otpLength) {
      _showSnackBar('أدخل رمز التحقق');
      return;
    }
    if (!_isValidPassword(_forgotPasswordController.text)) {
      _showSnackBar('كلمة المرور يجب أن تكون 8 أحرف وتحتوي حرفاً ورقماً');
      return;
    }
    if (_forgotPasswordController.text !=
        _forgotConfirmPasswordController.text) {
      _showSnackBar('كلمة المرور غير متطابقة');
      return;
    }
    await _runAuthAction(() async {
      final result = await AuthDependencies.resetPassword().call(
        requestId: _forgotRequestId!,
        code: _forgotOtpController.text.trim(),
        newPassword: _forgotPasswordController.text,
        confirmPassword: _forgotConfirmPasswordController.text,
      );
      if (!result.isSuccess) {
        throw _AuthUiException(
          _mapFailureMessage(result.failureOrNull?.message),
        );
      }
      if (!mounted) return;
      AppRouter.goToHome(context);
    });
  }

  Future<void> _runAuthAction(Future<void> Function() action) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      await action();
    } on _AuthUiException catch (error) {
      _showSnackBar(error.message);
    } catch (_) {
      _showSnackBar('يرجى المحاولة لاحقاً');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickBirthdate() async {
    final now = DateTime.now();
    final initial = _birthdate ?? DateTime(now.year - 22, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1920),
      lastDate: DateTime(now.year, now.month, now.day),
      helpText: 'تاريخ الميلاد',
      cancelText: 'إلغاء',
      confirmText: 'اختيار',
    );
    if (picked != null) {
      setState(() => _birthdate = picked);
    }
  }

  void _startRegistrationTimer() {
    _registrationTimer?.cancel();
    _registrationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_registrationResendSeconds <= 1) {
        timer.cancel();
        setState(() => _registrationResendSeconds = 0);
        return;
      }
      setState(() => _registrationResendSeconds--);
    });
  }

  void _startForgotTimer() {
    _forgotTimer?.cancel();
    _forgotTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_forgotResendSeconds <= 1) {
        timer.cancel();
        setState(() => _forgotResendSeconds = 0);
        return;
      }
      setState(() => _forgotResendSeconds--);
    });
  }

  bool _isAdult(DateTime birthdate) {
    final now = DateTime.now();
    var age = now.year - birthdate.year;
    if (now.month < birthdate.month ||
        (now.month == birthdate.month && now.day < birthdate.day)) {
      age--;
    }
    return age >= 18;
  }

  bool _isValidPassword(String value) {
    return value.length >= 8 &&
        RegExp(r'[A-Za-z\u0600-\u06FF]').hasMatch(value) &&
        RegExp(r'\d').hasMatch(value);
  }

  String _mapFailureMessage(String? raw) {
    final message = raw ?? '';
    final lowered = message.toLowerCase();
    if (lowered.contains('route not found') ||
        lowered.contains('page not found') ||
        lowered.contains('not found') ||
        lowered.contains('backend request failed')) {
      return 'الخدمة غير متاحة حالياً. يرجى تحديث التطبيق أو المحاولة لاحقاً.';
    }
    if (message.contains('username') || message.contains('اسم المستخدم')) {
      return 'اسم المستخدم مستخدم بالفعل';
    }
    if (message.contains('phone') || message.contains('رقم الهاتف')) {
      return 'رقم الهاتف مستخدم بالفعل';
    }
    if (message.contains('expired') || message.contains('صلاحية')) {
      return 'انتهت صلاحية الرمز';
    }
    if (message.contains('Invalid') || message.contains('رمز')) {
      return 'رمز التحقق غير صحيح';
    }
    if (message.contains('Too many') || message.contains('wait')) {
      return 'يرجى الانتظار قبل طلب رمز جديد';
    }
    return message.isEmpty ? 'يرجى المحاولة لاحقاً' : message;
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _RoleOption {
  const _RoleOption(this.value, this.label, this.icon);

  final String value;
  final String label;
  final IconData icon;
}

class _ProvinceOption {
  const _ProvinceOption(this.value, this.label);

  final String value;
  final String label;
}

class _AuthUiException implements Exception {
  const _AuthUiException(this.message);

  final String message;
}

class _AuthBackdrop extends StatelessWidget {
  const _AuthBackdrop();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF07111A), Color(0xFF0B1F2E), Color(0xFF05070B)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -110,
            right: -90,
            child: _GlowOrb(color: Color(0xFFB98B3D).withValues(alpha: .32)),
          ),
          Positioned(
            bottom: -130,
            left: -90,
            child: _GlowOrb(color: Color(0xFF2B6C7A).withValues(alpha: .24)),
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      height: 260,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [BoxShadow(color: color, blurRadius: 90, spreadRadius: 30)],
      ),
    );
  }
}

class _AuthGlassCard extends StatelessWidget {
  const _AuthGlassCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF111827).withValues(alpha: .72),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withValues(alpha: .08)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .32),
                blurRadius: 40,
                offset: const Offset(0, 24),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _AuthHeader extends StatelessWidget {
  const _AuthHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 62,
          height: 62,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Color(0xFFE7B85A), Color(0xFF8A6426)],
            ),
          ),
          child: const Icon(
            Icons.camera_alt_outlined,
            color: Color(0xFF0B0F14),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFFB8C0CC), fontSize: 14),
        ),
      ],
    );
  }
}

class _StepProgress extends StatelessWidget {
  const _StepProgress({required this.currentStep, required this.totalSteps});

  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'الخطوة $currentStep من $totalSteps',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFFE7B85A)),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            minHeight: 6,
            value: currentStep / totalSteps,
            backgroundColor: Colors.white.withValues(alpha: .08),
            valueColor: const AlwaysStoppedAnimation(Color(0xFFE7B85A)),
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.controller,
    required this.label,
    this.hint,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.textDirection,
    this.maxLength,
    this.suffixIcon,
    this.inputFormatters,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextDirection? textDirection;
  final int? maxLength;
  final Widget? suffixIcon;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textDirection: textDirection,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      onSubmitted: onSubmitted,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        counterStyle: const TextStyle(color: Color(0xFF6B7280)),
        labelStyle: const TextStyle(color: Color(0xFFB8C0CC)),
        hintStyle: const TextStyle(color: Color(0xFF657080)),
        suffixIcon: suffixIcon,
        suffixIconColor: const Color(0xFFE7B85A),
        filled: true,
        fillColor: Colors.white.withValues(alpha: .055),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: .08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFE7B85A)),
        ),
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.selected,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFE7B85A).withValues(alpha: .16)
              : Colors.white.withValues(alpha: .05),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? const Color(0xFFE7B85A)
                : Colors.white.withValues(alpha: .08),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFE7B85A)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle_rounded, color: Color(0xFFE7B85A)),
          ],
        ),
      ),
    );
  }
}

class _PickerTile extends StatelessWidget {
  const _PickerTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFFB8C0CC)),
          filled: true,
          fillColor: Colors.white.withValues(alpha: .055),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: .08)),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFE7B85A)),
            const SizedBox(width: 12),
            Text(value, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

class _DropdownTile extends StatelessWidget {
  const _DropdownTile({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String? value;
  final List<_ProvinceOption> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      dropdownColor: const Color(0xFF111827),
      iconEnabledColor: const Color(0xFFE7B85A),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFFB8C0CC)),
        filled: true,
        fillColor: Colors.white.withValues(alpha: .055),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: .08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFE7B85A)),
        ),
      ),
      items: items
          .map(
            (item) => DropdownMenuItem<String>(
              value: item.value,
              child: Text(item.label),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}

class _InfoText extends StatelessWidget {
  const _InfoText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(color: Color(0xFFE7B85A), fontSize: 13),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFFE7B85A),
        foregroundColor: const Color(0xFF0B0F14),
        disabledBackgroundColor: const Color(0xFF6B7280),
        minimumSize: const Size.fromHeight(54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
    );
  }
}

class _SecondaryActionButton extends StatelessWidget {
  const _SecondaryActionButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFFE7B85A),
        side: BorderSide(color: Colors.white.withValues(alpha: .14)),
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      child: Text(label),
    );
  }
}

class _SwitchModeButton extends StatelessWidget {
  const _SwitchModeButton({
    required this.prompt,
    required this.action,
    required this.onPressed,
  });

  final String prompt;
  final String action;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Color(0xFFB8C0CC)),
          children: [
            TextSpan(text: '$prompt '),
            TextSpan(
              text: action,
              style: const TextStyle(
                color: Color(0xFFE7B85A),
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthLoadingBarrier extends StatelessWidget {
  const _AuthLoadingBarrier();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black54,
      child: const Center(
        child: CircularProgressIndicator(color: Color(0xFFE7B85A)),
      ),
    );
  }
}
