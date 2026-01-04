import 'package:flutter/material.dart';
import 'package:luqta/core/constants/app_constants.dart';
import 'package:luqta/core/constants/app_theme.dart';
import 'package:luqta/core/router/app_router.dart';
import 'package:luqta/core/utils/debouncer.dart';
import 'package:luqta/core/widgets/app_buttons.dart';
import 'package:luqta/core/widgets/app_text_field.dart';
import 'package:luqta/features/auth/auth_dependencies.dart';
import 'package:luqta/features/profile/domain/entities/user_profile_update.dart';
import 'package:luqta/features/profile/profile_dependencies.dart';

class BasicInfoScreen extends StatefulWidget {
  final String userRole;

  const BasicInfoScreen({super.key, required this.userRole});

  @override
  State<BasicInfoScreen> createState() => _BasicInfoScreenState();
}

class _BasicInfoScreenState extends State<BasicInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _birthYearController = TextEditingController();
  final Debouncer _usernameDebouncer = Debouncer(
    delay: const Duration(milliseconds: 500),
  );

  String? _selectedGender;
  String? _selectedGovernorate;
  bool _over18Confirmed = false;
  bool _isCheckingUsername = false;
  bool _usernameAvailable = false;
  bool _isLoading = false;
  bool _isLoadingInitial = true;

  @override
  void initState() {
    super.initState();
    _loadExistingUser();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _fullNameController.dispose();
    _birthYearController.dispose();
    _usernameDebouncer.dispose();
    super.dispose();
  }

  Future<void> _loadExistingUser() async {
    final userResult = await AuthDependencies.getCurrentUser().call();
    final userId = userResult.valueOrNull?.id;
    if (userId == null || userId.isEmpty) {
      setState(() => _isLoadingInitial = false);
      return;
    }

    final result = await ProfileDependencies.getUserProfile().call(
      userId: userId,
    );
    final profile = result.valueOrNull;

    if (result.isSuccess && profile != null) {
      _usernameController.text = (profile.username ?? '').toString();
      _fullNameController.text = (profile.name).toString();
      final birthYearRaw = profile.birthYear;
      if (birthYearRaw != null && birthYearRaw.toString().isNotEmpty) {
        _birthYearController.text = birthYearRaw.toString();
      }
      _selectedGender = profile.gender;
      final govRaw = profile.governorate;
      if (govRaw.isNotEmpty &&
          AppConstants.iraqiGovernoratesAr.contains(govRaw)) {
        _selectedGovernorate = govRaw;
      } else {
        _selectedGovernorate = null;
      }
      _over18Confirmed = profile.over18Confirmed;
      if (_usernameController.text.trim().isNotEmpty) {
        _usernameAvailable = true;
      }
    }

    setState(() => _isLoadingInitial = false);
  }

  Future<void> _checkUsernameAvailability(String rawUsername) async {
    final username = rawUsername.trim().toLowerCase();
    if (username.length < 3) {
      setState(() {
        _isCheckingUsername = false;
        _usernameAvailable = false;
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
      });
    } catch (e) {
      setState(() {
        _isCheckingUsername = false;
        _usernameAvailable = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('حدث خطأ أثناء فحص اسم المستخدم')),
        );
      }
    }
  }

  Future<void> _saveAndContinue() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedGender == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('اختر الجنس من فضلك')));
      return;
    }
    if (_selectedGovernorate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('اختر المحافظة من فضلك')));
      return;
    }
    if (!_over18Confirmed) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('يجب تأكيد أنك فوق 18 سنة')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userResult = await AuthDependencies.getCurrentUser().call();
      final userId = userResult.valueOrNull?.id;
      if (userId == null || userId.isEmpty) {
        throw Exception('لم يتم العثور على مستخدم مسجل حالياً');
      }

      final username = _usernameController.text.trim().toLowerCase();
      final birthYear = int.tryParse(_birthYearController.text.trim());
      final age = birthYear != null ? DateTime.now().year - birthYear : null;

      final data = BasicInfoData(
        role: widget.userRole,
        name: _fullNameController.text.trim(),
        username: username,
        governorate: _selectedGovernorate!,
        gender: _selectedGender,
        birthYear: birthYear,
        age: age,
        over18Confirmed: _over18Confirmed,
        profileCompleted: true,
      );
      final result = await ProfileDependencies.saveBasicInfo().call(
        userId: userId,
        data: data,
      );
      if (!result.isSuccess) {
        throw StateError(result.failureOrNull?.message ?? 'Save failed');
      }
      AppRouter.invalidateProfileCache(userId);

      setState(() => _isLoading = false);

      if (!mounted) return;
      AppRouter.goToHome(context);
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('حدث خطأ أثناء الحفظ')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingInitial) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('المعلومات الأساسية'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.cta],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              Text('اسم المستخدم (Username)', style: AppTypography.h4),
              const SizedBox(height: 8),
              AppTextField(
                controller: _usernameController,
                hint: 'مثال: ahmedphoto23',
                prefixIcon: Icons.person_outline,
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
                  _usernameDebouncer(
                    () => _checkUsernameAvailability(normalized),
                  );
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال اسم المستخدم';
                  }
                  final normalized = value.trim().toLowerCase();
                  final regex = RegExp(r'^[a-z][a-z0-9]*$');
                  if (!regex.hasMatch(normalized)) {
                    return 'اسم المستخدم يجب أن يبدأ بحرف ويحتوي حروفاً أو أرقاماً فقط (بدون مسافات)';
                  }
                  if (normalized.length < 3) {
                    return 'يجب ألا يقل عن 3 أحرف';
                  }
                  if (!_usernameAvailable && !_isCheckingUsername) {
                    return 'اسم المستخدم غير متاح';
                  }
                  return null;
                },
              ),
              if (_isCheckingUsername)
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text(
                    'جارٍ التحقق...',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              if (_usernameAvailable && !_isCheckingUsername)
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 16,
                        color: AppColors.success,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'اسم المستخدم متاح',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              if (!_usernameAvailable &&
                  !_isCheckingUsername &&
                  _usernameController.text.length >= 3)
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      Icon(Icons.error, size: 16, color: AppColors.error),
                      SizedBox(width: 4),
                      Text(
                        'اسم المستخدم غير متاح',
                        style: TextStyle(fontSize: 12, color: AppColors.error),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),

              Text('الاسم الكامل', style: AppTypography.h4),
              const SizedBox(height: 8),
              AppTextField(
                controller: _fullNameController,
                hint: 'اكتب اسمك الكامل',
                prefixIcon: Icons.badge_outlined,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الاسم الكامل مطلوب';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              Text('الجنس', style: AppTypography.h4),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _GenderOption(
                      icon: Icons.male,
                      label: 'ذكر',
                      isSelected: _selectedGender == 'male',
                      onTap: () => setState(() => _selectedGender = 'male'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _GenderOption(
                      icon: Icons.female,
                      label: 'أنثى',
                      isSelected: _selectedGender == 'female',
                      onTap: () => setState(() => _selectedGender = 'female'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Text('سنة الميلاد', style: AppTypography.h4),
              const SizedBox(height: 8),
              AppTextField(
                controller: _birthYearController,
                hint: 'مثال: 1995',
                prefixIcon: Icons.cake,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال سنة الميلاد';
                  }
                  final year = int.tryParse(value);
                  if (year == null ||
                      year < 1900 ||
                      year > DateTime.now().year - 18) {
                    return 'يجب أن تشير سنة الميلاد إلى عمر 18 عاماً أو أكثر';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              Text('المحافظة', style: AppTypography.h4),
              const SizedBox(height: 8),
              AppDropdownField<String>(
                initialValue: _selectedGovernorate,
                hint: 'اختر المحافظة',
                prefixIcon: Icons.location_on,
                items: AppConstants.iraqiGovernoratesAr.map((gov) {
                  return DropdownMenuItem(value: gov, child: Text(gov));
                }).toList(),
                onChanged: (value) =>
                    setState(() => _selectedGovernorate = value),
              ),
              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Checkbox(
                      value: _over18Confirmed,
                      onChanged: (value) {
                        setState(() => _over18Confirmed = value ?? false);
                      },
                      activeColor: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'أؤكد أن عمري فوق 18 سنة',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              CTAButton(
                text: 'متابعة',
                onPressed: _saveAndContinue,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _GenderOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.surface,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 40,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
