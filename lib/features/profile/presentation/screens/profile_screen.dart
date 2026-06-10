import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:laqta/core/constants/app_constants.dart';
import 'package:laqta/core/localization/app_localizations.dart';
import 'package:laqta/core/media/image_picker_service.dart';
import 'package:laqta/core/models/user_model.dart';
import 'package:laqta/app/router/app_router.dart';
import 'package:laqta/core/widgets/app_buttons.dart';
import 'package:laqta/core/widgets/app_text_field.dart';
import 'package:laqta/core/widgets/laqta_async_widgets.dart';
import 'package:laqta/features/auth/auth_dependencies.dart';
import 'package:laqta/features/auth/data/utils/phone_number_utils.dart';
import 'package:laqta/features/profile/domain/entities/user_profile_update.dart';
import 'package:laqta/features/profile/profile_dependencies.dart';
import 'package:laqta/features/profile/presentation/mappers/profile_presentation_mapper.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _user;
  bool _isLoading = true;
  bool _isUploading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final authResult = await AuthDependencies.getCurrentUser().call();
    final authUser = authResult.valueOrNull;
    if (authUser == null) {
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          AppRouter.goToAuth(context);
        }
      });
      return;
    }

    try {
      final result = await ProfileDependencies.getUserProfile().call(
        userId: authUser.id,
      );
      if (!result.isSuccess || result.valueOrNull == null) {
        throw StateError(result.failureOrNull?.message ?? 'User not found');
      }

      if (!mounted) return;
      setState(() {
        _user = ProfilePresentationMapper.toUserModel(result.valueOrNull!);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'تعذّر تحميل الملف الشخصي';
        _isLoading = false;
      });
    }
  }

  Future<void> _updateUser(Map<String, dynamic> updates) async {
    final authResult = await AuthDependencies.getCurrentUser().call();
    final authUser = authResult.valueOrNull;
    if (authUser == null || _user == null) return;

    final update = UserProfileUpdate(
      name: updates['name'] as String?,
      email: updates['email'] as String?,
      phone: updates['phone'] as String?,
      governorate: updates['governorate'] as String?,
      photoUrl: updates['photoUrl'] as String?,
      username: updates['username'] as String?,
      gender: updates['gender'] as String?,
      age: updates['age'] as int?,
      birthYear: updates['birthYear'] as int?,
      role: updates['role'] as String?,
      profileCompleted: updates['profileCompleted'] as bool?,
      over18Confirmed: updates['over18Confirmed'] as bool?,
    );
    final result = await ProfileDependencies.updateUserProfile().call(
      userId: authUser.id,
      update: update,
    );
    if (!result.isSuccess) {
      throw StateError(result.failureOrNull?.message ?? 'Update failed');
    }

    if (!mounted) return;
    setState(() {
      _user = _user!.copyWith(
        role: updates['role'] as String? ?? _user!.role,
        name: updates['name'] as String? ?? _user!.name,
        username: updates['username'] as String? ?? _user!.username,
        email: updates['email'] as String? ?? _user!.email,
        phone: updates['phone'] as String? ?? _user!.phone,
        governorate: updates['governorate'] as String? ?? _user!.governorate,
        photoUrl: updates['photoUrl'] as String? ?? _user!.photoUrl,
        gender: updates['gender'] as String? ?? _user!.gender,
        age: updates['age'] as int? ?? _user!.age,
        birthYear: updates['birthYear'] as int? ?? _user!.birthYear,
        profileCompleted:
            updates['profileCompleted'] as bool? ?? _user!.profileCompleted,
        over18Confirmed:
            updates['over18Confirmed'] as bool? ?? _user!.over18Confirmed,
      );
    });
  }

  Future<void> _uploadPhoto() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final pickedFile = await ImagePickerService().pickImageToTemp(
        source: ImageSource.gallery,
      );
      if (!mounted) return;

      if (pickedFile == null) return;

      setState(() => _isUploading = true);

      try {
        final userResult = await AuthDependencies.getCurrentUser().call();
        final userId = userResult.valueOrNull?.id;
        if (userId == null || userId.isEmpty) {
          throw StateError('Missing current user');
        }

        final result = await ProfileDependencies.uploadProfilePhoto().call(
          userId: userId,
          filePath: pickedFile.path,
        );
        if (!result.isSuccess || result.valueOrNull == null) {
          throw StateError('Upload failed');
        }
        final downloadUrl = result.valueOrNull!;

        await _updateUser({'photoUrl': downloadUrl});

        if (!mounted) return;
        messenger.showSnackBar(
          const SnackBar(content: Text('تم تحديث صورة الملف الشخصي')),
        );
      } finally {
        if (mounted) {
          setState(() => _isUploading = false);
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUploading = false);
      messenger.showSnackBar(const SnackBar(content: Text('فشل رفع الصورة')));
    }
  }

  Future<void> _editField(String fieldKey, String title) async {
    if (_user == null) return;
    final messenger = ScaffoldMessenger.of(context);
    final controller = TextEditingController(
      text: fieldKey == 'governorate'
          ? _user!.governorate
          : (_user!.toFirestore()[fieldKey] ?? '').toString(),
    );
    final newValue = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تعديل $title'),
        content: AppTextField(
          controller: controller,
          hint: 'اكتب $title',
          label: title,
          keyboardType: fieldKey == 'phone'
              ? TextInputType.phone
              : TextInputType.text,
          textInputAction: TextInputAction.done,
          autofocus: true,
          onFieldSubmitted: (_) {
            final value = controller.text.trim();
            if (value.isEmpty) {
              messenger.showSnackBar(
                SnackBar(content: Text('$title لا يمكن أن يكون فارغاً')),
              );
              return;
            }
            Navigator.of(context).pop(value);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              final value = controller.text.trim();
              if (value.isEmpty) {
                messenger.showSnackBar(
                  SnackBar(content: Text('$title لا يمكن أن يكون فارغاً')),
                );
                return;
              }
              Navigator.of(context).pop(value);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );

    if (newValue != null) {
      try {
        await _updateUser({fieldKey: newValue});
        messenger.showSnackBar(
          SnackBar(content: Text('تم تحديث $title بنجاح')),
        );
      } catch (e) {
        messenger.showSnackBar(SnackBar(content: Text('تعذّر تحديث $title')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('حسابي')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 64, color: scheme.error),
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  style: textTheme.bodyLarge?.copyWith(color: scheme.error),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                CTAButton(text: 'إعادة المحاولة', onPressed: _loadUser),
                const SizedBox(height: 8),
                SecondaryButton(
                  text: 'إكمال البيانات الأساسية',
                  onPressed: () => AppRouter.goToBasicInfo(
                    context,
                    AppConstants.roleCustomer,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final user = _user!;
    final genderLabel = user.gender == 'female'
        ? 'أنثى'
        : user.gender == 'male'
        ? 'ذكر'
        : null;
    final ageLabel = user.age != null ? '${user.age} سنة' : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('حسابي'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => AppRouter.goToSettings(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  ClipOval(
                    child: SizedBox(
                      width: 120,
                      height: 120,
                      child: user.photoUrl != null && user.photoUrl!.isNotEmpty
                          ? LaqtaRemoteImage(
                              imageUrl: user.photoUrl,
                              width: 120,
                              height: 120,
                              borderRadius: BorderRadius.circular(60),
                            )
                          : DecoratedBox(
                              decoration: BoxDecoration(color: scheme.primary),
                              child: const Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: scheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: IconButton(
                        icon: _isUploading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Icon(Icons.camera_alt, size: 20),
                        color: Colors.white,
                        onPressed: _isUploading ? null : _uploadPhoto,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Text(
              user.name,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            if (user.username != null && user.username!.isNotEmpty)
              Text(
                '@${user.username}',
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildChip(
                  icon: Icons.verified_user,
                  label: user.role == AppConstants.roleAdmin
                      ? 'Admin'
                      : user.role == AppConstants.rolePhotographer
                      ? localizations.photographer
                      : localizations.customer,
                  color: scheme.primary,
                ),
                if (genderLabel != null)
                  _buildChip(
                    icon: user.gender == 'female' ? Icons.female : Icons.male,
                    label: genderLabel,
                    color: scheme.secondary,
                  ),
                if (ageLabel != null)
                  _buildChip(
                    icon: Icons.cake,
                    label: ageLabel,
                    color: scheme.primary,
                  ),
                if (user.governorate.isNotEmpty)
                  _buildChip(
                    icon: Icons.location_on,
                    label: user.governorate,
                    color: scheme.tertiary,
                  ),
              ],
            ),
            const SizedBox(height: 24),

            _buildInfoCard(
              icon: Icons.email,
              title: 'Email',
              value: user.email ?? 'غير مضاف',
              fieldKey: 'email',
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              icon: Icons.phone,
              title: localizations.phoneNumber,
              value: user.phone == null || user.phone!.trim().isEmpty
                  ? 'غير مضاف'
                  : formatPhoneNumberForDisplay(user.phone),
              fieldKey: 'phone',
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              icon: Icons.person_outline,
              title: 'اسم المستخدم',
              value: user.username ?? 'غير مضاف',
              fieldKey: 'username',
              editable: false,
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              icon: Icons.location_on,
              title: localizations.governorate,
              value: user.governorate.isNotEmpty
                  ? user.governorate
                  : 'غير مضاف',
              fieldKey: 'governorate',
            ),
            const SizedBox(height: 24),

            if (user.role == AppConstants.roleCustomer) ...[
              PrimaryButton(
                text: localizations.myBookings,
                icon: Icons.calendar_today,
                onPressed: () {
                  AppRouter.goToBookings(context);
                },
              ),
              const SizedBox(height: 12),
              SecondaryButton(
                text: localizations.favorites,
                icon: Icons.favorite,
                onPressed: () {
                  AppRouter.goToFavorites(context);
                },
              ),
            ] else if (user.role == AppConstants.rolePhotographer) ...[
              PrimaryButton(
                text: localizations.dashboard,
                icon: Icons.dashboard,
                onPressed: () {
                  AppRouter.goToDashboard(context);
                },
              ),
              const SizedBox(height: 12),
              SecondaryButton(
                text: 'معرض الأعمال',
                icon: Icons.photo_library,
                onPressed: () {
                  AppRouter.goToPortfolioEditor(context);
                },
              ),
              const SizedBox(height: 12),
              SecondaryButton(
                text: 'الباقات والاشتراكات',
                icon: Icons.workspace_premium_outlined,
                onPressed: () {
                  AppRouter.goToSubscriptionPlans(context);
                },
              ),
              const SizedBox(height: 12),
              SecondaryButton(
                text: 'إعلان ممول',
                icon: Icons.campaign_outlined,
                onPressed: () {
                  AppRouter.goToSponsoredAd(context);
                },
              ),
              const SizedBox(height: 12),
              SecondaryButton(
                text: 'توثيق الحساب',
                icon: Icons.verified_user_outlined,
                onPressed: () {
                  AppRouter.goToPhotographerVerification(context);
                },
              ),
            ] else ...[
              PrimaryButton(
                text: 'لوحة تحكم الإدارة',
                icon: Icons.admin_panel_settings,
                onPressed: () {
                  AppRouter.goToHome(context);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required String fieldKey,
    bool editable = true,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: scheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: textTheme.labelSmall),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (editable)
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              color: scheme.onSurfaceVariant,
              onPressed: () => _editField(fieldKey, title),
            ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required IconData icon,
    required String label,
    Color? color,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final chipColor = color ?? scheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: chipColor.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: chipColor),
          const SizedBox(width: 6),
          Text(label, style: textTheme.bodySmall),
        ],
      ),
    );
  }
}
