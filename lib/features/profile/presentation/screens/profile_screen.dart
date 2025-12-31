import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:luqta/core/constants/app_theme.dart';
import 'package:luqta/core/constants/app_constants.dart';
import 'package:luqta/core/localization/app_localizations.dart';
import 'package:luqta/core/models/user_model.dart';
import 'package:luqta/core/router/app_router.dart';
import 'package:luqta/core/widgets/app_buttons.dart';
import 'package:luqta/core/widgets/app_text_field.dart';
import 'package:luqta/features/auth/auth_dependencies.dart';
import 'package:luqta/features/profile/domain/entities/user_profile_update.dart';
import 'package:luqta/features/profile/profile_dependencies.dart';
import 'package:luqta/features/profile/presentation/mappers/profile_presentation_mapper.dart';

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
      setState(() {
        _errorMessage = 'الرجاء تسجيل الدخول لعرض الحساب';
        _isLoading = false;
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

      setState(() {
        _user = ProfilePresentationMapper.toUserModel(result.valueOrNull!);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'تعذّر تحميل الملف الشخصي: $e';
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

    setState(() {
      _user = _user!.copyWith(
        name: updates['name'] as String? ?? _user!.name,
        email: updates['email'] as String? ?? _user!.email,
        phone: updates['phone'] as String? ?? _user!.phone,
        governorate: updates['governorate'] as String? ?? _user!.governorate,
        photoUrl: updates['photoUrl'] as String? ?? _user!.photoUrl,
      );
    });
  }

  Future<void> _uploadPhoto() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() => _isUploading = true);

        final userResult = await AuthDependencies.getCurrentUser().call();
        final userId = userResult.valueOrNull?.id;
        if (userId == null || userId.isEmpty) return;

        final result = await ProfileDependencies.uploadProfilePhoto().call(
          userId: userId,
          filePath: pickedFile.path,
        );
        if (!result.isSuccess || result.valueOrNull == null) {
          throw StateError('Upload failed');
        }
        final downloadUrl = result.valueOrNull!;

        await _updateUser({'photoUrl': downloadUrl});

        setState(() => _isUploading = false);

        messenger.showSnackBar(
          const SnackBar(content: Text('تم تحديث صورة الملف الشخصي')),
        );
      }
    } catch (e) {
      setState(() => _isUploading = false);
      messenger.showSnackBar(SnackBar(content: Text('فشل رفع الصورة: $e')));
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
        messenger.showSnackBar(
          SnackBar(content: Text('تعذّر تحديث $title: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

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
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColors.error,
                ),
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  style: AppTypography.bodyLarge,
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
      backgroundColor: AppColors.background,
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
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: AppColors.primary,
                    backgroundImage: user.photoUrl != null
                        ? NetworkImage(user.photoUrl!)
                        : null,
                    child: user.photoUrl == null
                        ? const Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary,
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
              style: AppTypography.h2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            if (user.username != null && user.username!.isNotEmpty)
              Text(
                '@${user.username}',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
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
                  label: user.role == AppConstants.rolePhotographer
                      ? localizations.photographer
                      : localizations.customer,
                  color: AppColors.primary,
                ),
                if (genderLabel != null)
                  _buildChip(
                    icon: user.gender == 'female' ? Icons.female : Icons.male,
                    label: genderLabel,
                    color: AppColors.cta,
                  ),
                if (ageLabel != null)
                  _buildChip(
                    icon: Icons.cake,
                    label: ageLabel,
                    color: AppColors.info,
                  ),
                if (user.governorate.isNotEmpty)
                  _buildChip(
                    icon: Icons.location_on,
                    label: user.governorate,
                    color: AppColors.success,
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
              value: user.phone ?? 'غير مضاف',
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
            ] else ...[
              PrimaryButton(
                text: localizations.dashboard,
                icon: Icons.dashboard,
                onPressed: () {
                  AppRouter.goToDashboard(context);
                },
              ),
              const SizedBox(height: 12),
              SecondaryButton(
                text: 'Edit Portfolio',
                icon: Icons.photo_library,
                onPressed: () {
                  AppRouter.goToPortfolioEditor(context);
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.caption),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (editable)
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              color: AppColors.textSecondary,
              onPressed: () => _editField(fieldKey, title),
            ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required IconData icon,
    required String label,
    Color color = AppColors.primary,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(label, style: AppTypography.bodySmall),
        ],
      ),
    );
  }
}
